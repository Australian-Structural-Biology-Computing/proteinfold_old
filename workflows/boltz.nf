/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Loaded from modules/local/
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { MULTIQC } from '../modules/nf-core/multiqc/main'
include { CREATE_SAMPLESHEET_YAML } from '../modules/local/create_samplesheet'
include { CREATE_SAMPLESHEET_YAML_MSA } from '../modules/local/create_samplesheet_msa'
include { MMSEQS_COLABFOLDSEARCH } from '../modules/local/mmseqs_colabfoldsearch'

//
// SUBWORKFLOW: Consisting entirely of nf-core/modules
//
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_proteinfold_pipeline'

//
// MODULE: Boltz
//
include { RUN_BOLTZ } from '../modules/local/run_boltz'
include { RUN_BOLTZ_MSA } from '../modules/local/run_boltz_msa'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BOLTZ {

    take:
    ch_samplesheet  // channel: samplesheet read from --input
    ch_versions     // channel: [ path(versions.yml) ]
    ch_boltz_ccd    // channel: [ path(boltz_ccd) ]
    ch_boltz_model  // channel: [ path(model) ]
    ch_colabfold_params // channel: [ path(colabfold_params) ]
    ch_colabfold_db // channel: [ path(colabfold_db) ]
    ch_uniref30     // channel: [ path(uniref30) ]

    main:
    ch_multiqc_files = Channel.empty()
    // MMSEQS_COLABFOLDSEARCH
    MMSEQS_COLABFOLDSEARCH (
        ch_samplesheet,
        ch_colabfold_params,
        ch_colabfold_db,
        ch_uniref30
    )
    
    ch_versions = ch_versions.mix(MMSEQS_COLABFOLDSEARCH.out.versions)

    // CREATE_SAMPLESHEET_YAML
    CREATE_SAMPLESHEET_YAML_MSA(
        ch_samplesheet,
        MMSEQS_COLABFOLDSEARCH.out.a3m
    )
        //MMSEQS_COLABFOLDSEARCH.out.a3m

    // RUN_BOLTZ 
    RUN_BOLTZ_MSA(
        CREATE_SAMPLESHEET_YAML_MSA.out.samplesheet,
        ch_boltz_model,
        ch_boltz_ccd,
        MMSEQS_COLABFOLDSEARCH.out.a3m
    )

    emit:
    versions   = ch_versions
    msa        = RUN_BOLTZ_MSA.out.msa
    structures = RUN_BOLTZ_MSA.out.structures
    confidence = RUN_BOLTZ_MSA.out.confidence
    plddt      = RUN_BOLTZ_MSA.out.plddt
} 
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
