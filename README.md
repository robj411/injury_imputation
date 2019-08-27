# injury imputation

At the top level, we put our code and three directories: one for raw data, one for processed data, and one for outputs.

Raw data are travel surveys and injury records.

We need a script to take raw_data/trips and make processed distance data: processed_data/distances.

Similarly, we need a script to take raw_data/injuries and make processed whw matrices: processed_data/whw_matrices.

Once we have all these, we will write a function to generate predictions using processed_data to save in outputs.

Finally we will test the results.
