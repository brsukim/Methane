# Methane
This is a repository for the Methane project that Brandon worked on at the JGCRI during his summer term.

The purpose of this project is to visualize trends of CH4 flux from soil to atmosphere in response to certain variables, both quantitative and categorical. 

# The Methane Database
The Methane Database (`CH4_8.15.csv`) is a comprehensive spreadsheet of 72 research papers that include data on CH4 flux, soil moisture, and a variety of other auxiliary variables
Using a few Python scripts (`Paper Scraper` folder) and manual data ingestion, we were able to create this database that you can access.

# Data flow
The dataset, formatted as a csv, has areas of weaknesses and is not in an acceptable shape for our ultimate analysis, which is a principal component analysis. To be able to access the data within the dataset, we must format the data into a new dataframe that can be "digested" by R and other PCA functions.

`DataDigester.R` standardizes and adjusts the dataframe into a csv called `final_data.csv`

The `final_data.csv` is sent to the `initialPCA.Rmd` where the PCA occurs and results can be seen.

# Contact
Any questions regarding this project can be sent to my email at brandonskim24@gmail.com
