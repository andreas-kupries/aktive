<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|Strict|[Implementations ↘](bylang.md)|

|||||||
|---|---|---|---|---|---|
|&nbsp;[f](#_f)&nbsp;|&nbsp;[i](#_i)&nbsp;|&nbsp;[o](#_o)&nbsp;|&nbsp;[q](#_q)&nbsp;|&nbsp;[t](#_t)&nbsp;|&nbsp;[w](#_w)&nbsp;|

# Documentation -- Reference Pages -- StrictOperators

All operators listed here are strict in at least one of their image arguments.

This means that these operators execute the image pipelines to calculate the
pixels of the input images they are strict in.

Note that this does not necessarily mean that these inputs are fully materialized
in memory, only that the pixels are computed. These pixels may then be saved
to disk, or reduced by some statistical measure, or, yes, indeed materialized.

It all depends on the details of the operator in question.

## <a name='_f'></a> f

 - [aktive format as aktive 2chan](sink_writer.md#format_as_aktive_2chan)
 - [aktive format as aktive 2file](sink_writer.md#format_as_aktive_2file)
 - [aktive format as aktive 2string](sink_writer.md#format_as_aktive_2string)
 - [aktive format as null-s 2string](sink_writer.md#format_as_null_s_2string)
 - [aktive format as null 2string](sink_writer.md#format_as_null_2string)
 - [aktive format as pgm byte 2chan](sink_writer.md#format_as_pgm_byte_2chan)
 - [aktive format as pgm byte 2file](sink_writer.md#format_as_pgm_byte_2file)
 - [aktive format as pgm byte 2string](sink_writer.md#format_as_pgm_byte_2string)
 - [aktive format as pgm etext 2chan](sink_writer.md#format_as_pgm_etext_2chan)
 - [aktive format as pgm etext 2file](sink_writer.md#format_as_pgm_etext_2file)
 - [aktive format as pgm etext 2string](sink_writer.md#format_as_pgm_etext_2string)
 - [aktive format as pgm short 2chan](sink_writer.md#format_as_pgm_short_2chan)
 - [aktive format as pgm short 2file](sink_writer.md#format_as_pgm_short_2file)
 - [aktive format as pgm short 2string](sink_writer.md#format_as_pgm_short_2string)
 - [aktive format as pgm text 2chan](sink_writer.md#format_as_pgm_text_2chan)
 - [aktive format as pgm text 2file](sink_writer.md#format_as_pgm_text_2file)
 - [aktive format as pgm text 2string](sink_writer.md#format_as_pgm_text_2string)
 - [aktive format as ppm byte 2chan](sink_writer.md#format_as_ppm_byte_2chan)
 - [aktive format as ppm byte 2file](sink_writer.md#format_as_ppm_byte_2file)
 - [aktive format as ppm byte 2string](sink_writer.md#format_as_ppm_byte_2string)
 - [aktive format as ppm etext 2chan](sink_writer.md#format_as_ppm_etext_2chan)
 - [aktive format as ppm etext 2file](sink_writer.md#format_as_ppm_etext_2file)
 - [aktive format as ppm etext 2string](sink_writer.md#format_as_ppm_etext_2string)
 - [aktive format as ppm short 2chan](sink_writer.md#format_as_ppm_short_2chan)
 - [aktive format as ppm short 2file](sink_writer.md#format_as_ppm_short_2file)
 - [aktive format as ppm short 2string](sink_writer.md#format_as_ppm_short_2string)
 - [aktive format as ppm text 2chan](sink_writer.md#format_as_ppm_text_2chan)
 - [aktive format as ppm text 2file](sink_writer.md#format_as_ppm_text_2file)
 - [aktive format as ppm text 2string](sink_writer.md#format_as_ppm_text_2string)
 - [aktive format as tcl](sink_writer.md#format_as_tcl)

## <a name='_i'></a> i

 - [aktive image threshold global bernsen](accessor_threshold_generate.md#image_threshold_global_bernsen)
 - [aktive image threshold global mean](accessor_threshold_generate.md#image_threshold_global_mean)
 - [aktive image threshold global niblack](accessor_threshold_generate.md#image_threshold_global_niblack)
 - [aktive image threshold global otsu](accessor_threshold_generate.md#image_threshold_global_otsu)
 - [aktive image threshold global phansalkar](accessor_threshold_generate.md#image_threshold_global_phansalkar)
 - [aktive image threshold global sauvola](accessor_threshold_generate.md#image_threshold_global_sauvola)

## <a name='_o'></a> o

 - [aktive op compare mse](sink_statistics.md#op_compare_mse)
 - [aktive op compare rmse](sink_statistics.md#op_compare_rmse)
 - [aktive op connected-components labeled](transform_morphology.md#op_connected_components_labeled)
 - [aktive op convolve xy](transform_convolution.md#op_convolve_xy)
 - [aktive op image max](sink_statistics.md#op_image_max)
 - [aktive op image mean](sink_statistics.md#op_image_mean)
 - [aktive op image mean-stddev](sink_statistics.md#op_image_mean_stddev)
 - [aktive op image min](sink_statistics.md#op_image_min)
 - [aktive op image min-max](sink_statistics.md#op_image_min_max)
 - [aktive op image stddev](sink_statistics.md#op_image_stddev)
 - [aktive op image sum](sink_statistics.md#op_image_sum)
 - [aktive op image sumsquared](sink_statistics.md#op_image_sumsquared)
 - [aktive op image variance](sink_statistics.md#op_image_variance)
 - [aktive op lut indexed](transform_lookup_indexed.md#op_lut_indexed)
 - [aktive op transform by](transform_structure_warp.md#op_transform_by)

## <a name='_q'></a> q

 - [aktive query value around](accessor_values.md#query_value_around)
 - [aktive query value at](accessor_values.md#query_value_at)
 - [aktive query values](accessor_values.md#query_values)

## <a name='_t'></a> t

 - [aktive transform box](generator_virtual_warp.md#transform_box)
 - [aktive transform compose](generator_virtual_warp.md#transform_compose)
 - [aktive transform compose-core](generator_virtual_warp.md#transform_compose_core)
 - [aktive transform invert](generator_virtual_warp.md#transform_invert)

## <a name='_w'></a> w

 - [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

