process TRIMDIVERSITY_OVATION {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=2.7"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:2.7' :
        'biocontainers/python:2.7' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_trimmed.fq.gz")  , emit: reads
    path "versions.yml"                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    // Added soft-links to original fastqs for consistent naming in MultiQC
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (meta.single_end) {
        """
        trimRRBSdiversityAdaptCustomers.py -1 $reads
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$(python --version | sed 's/Python //g')
        END_VERSIONS
        """
    } else {
        """
        trimRRBSdiversityAdaptCustomers.py -1 ${reads[0]} -2 ${reads[1]}
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$(python --version | sed 's/Python //g')
        END_VERSIONS
        """
    }
}
