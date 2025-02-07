/*
 * Run Boltz
 */
process RUN_BOLTZ {
    tag "$meta.id"
    label 'process_medium'

    container "/srv/scratch/sbf-pipelines/proteinfold/singularity/boltz.sif"

    input:
    tuple val(meta), path(fasta)
    path ('boltz1_conf.ckpt')
    path ('ccd.pkl')

    output:
    path ("boltz_results_${fasta.baseName}/processed/msa/*.npz"), emit: msa
    path ("boltz_results_${fasta.baseName}/processed/structures/*.npz"), emit: structures
    path ("boltz_results_${fasta.baseName}/predictions/${fasta.baseName}/confidence*.json"), emit: confidence
    path ("boltz_results_${fasta.baseName}/predictions/${fasta.baseName}/plddt_*.npz"), emit: plddt
    path ("boltz_results_${fasta.baseName}/predictions/${fasta.baseName}/*.cif"), emit: cif
    path ("boltz_results_${fasta.baseName}/predictions/${fasta.baseName}/*.pdb"), emit: pdb

    script:
    """
    boltz predict --use_msa_server "./${fasta.name}" --cache ./
    """
}
