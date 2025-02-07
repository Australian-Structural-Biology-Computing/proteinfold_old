process CREATE_SAMPLESHEET_YAML_MSA {
    tag "$meta.id"
    label 'process_single'

    container 'docker://nbtmsh/samplesheet-utils:1.1'

    input:
    tuple val(meta), path(samplesheet)
    path("**.a3m")

    output:
    tuple val(meta), path("*.yaml"), emit: samplesheet

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    create-samplesheet \\
        --directory ./ \\
        --msa-dir ./ \\
        --yaml \
        --output-file \$(sample-name --sanitise --index 0 ./*.fasta).yaml
    """

    stub:
    """
    echo "" > samplesheet.yaml
    """
}

