process EXPORT_META {
    label 'process_min'

    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'ubuntu:20.04' }"

    input:
    val meta
    val table_name

    output:
    path "*.csv", emit: csv

    when:
    task.ext.when == null || task.ext.when

    script:
    def header = [:]

    // Find the header key set
    for (int i = 0; i < meta.size(); i++) {
        meta[i].each {
            entry ->
                if(!header.containsKey(entry.key)) {
                    header.put(entry.key, null)
                }
        }
    }

    // Init output string
    arr_str = header.keySet().join(",")

    // Map the values and write row
    for (int i = 0; i < meta.size(); i++) {
        header.each {
            entry ->
                entry.value = null
        }

        meta[i].each {
            entry ->
                header[entry.key] = entry.value
        }
        sample_str = header.values().join(",")
        arr_str =  arr_str + "\n" + sample_str
    }

    """
    echo "$arr_str" > ${table_name}.csv
    """
}
