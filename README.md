# injury imputation

At the top level, we put our code and three directories: one for raw data, one for processed data, and one for outputs.

Raw data are travel surveys and injury records.

We need a script to take raw_data/trips and make processed distance data: processed_data/distances. files in processed_data/distances/ should contain a table with two columns: one should be mode name and the other the total distances travelled for the whole population. The modes need to match the modes in injuries and in the other cities. The distances should be in km.

To get distance for the whole city, we need population numbers. We can take these from links of the form
https://github.com/ITHIM/ITHIM-R/blob/master/inst/extdata/local/belo_horizonte/population_belo_horizonte.csv

Similarly, we need a script to take raw_data/injuries and make processed whw matrices: processed_data/whw_matrices.

Once we have all these, we will write a function to generate predictions using processed_data to save in outputs.

Finally we will test the results.
