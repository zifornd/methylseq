process NUDUP {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::bismark=0.24.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bismark:0.24.0--hdfd78af_0' :
        'biocontainers/bismark:0.24.0--hdfd78af_0' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.sorted.markdup.bam")  , emit: bam
    tuple val(meta), path("*_dup_log.txt")         , emit: log
    path  "versions.yml"                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    if (meta.single_end) {
        def args_list = args.split("\\s(?=--)").toList()
        args_list.removeAll { it.toLowerCase().contains('_r2 ') }
        """
        nudup.py –f index.fq –o outputname $bam
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            trimgalore: \$(echo \$(trim_galore --version 2>&1) | sed 's/^.*version //; s/Last.*\$//')
            cutadapt: \$(cutadapt --version)
        END_VERSIONS
        """
    } else {
        """
        nudup.py –2 –f index.fq –o outputname $bam
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            trimgalore: \$(echo \$(trim_galore --version 2>&1) | sed 's/^.*version //; s/Last.*\$//')
            cutadapt: \$(cutadapt --version)
        END_VERSIONS
        """
    }
}
