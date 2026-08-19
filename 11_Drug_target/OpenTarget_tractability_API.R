# Install relevant library for HTTP requests
library(httr)
library(jsonlite)  # For JSON processing
library(dplyr)     # For data manipulation

# Set multiple gene IDs
prior_genes = read.table("credible_gene.list",header =T)
gene_ids = prior_genes$ensembl

# Build query string to get general information about genes
query_string <- "
  query target($ensemblId: String!){
    target(ensemblId: $ensemblId){
      id
      approvedSymbol
      biotype
      tractability {
        label
        modality
        value
      }
    }
  }
"

# Set base URL of GraphQL API endpoint
base_url <- "https://api.platform.opentargets.org/api/v4/graphql"

# Initialize empty data frames for results
tractability_all <- data.frame()

# Iterate over each gene ID
for (gene_id in gene_ids) {
  # Set variables object of arguments to be passed to endpoint
  variables <- list("ensemblId" = gene_id)

  # Construct POST request body object with query string and variables
  post_body <- list(query = query_string, variables = variables)

  # Perform POST request
  response <- POST(url = base_url, body = post_body, encode = 'json')

  # Parse response content
  response_data <- content(response, as = "parsed", simplifyVector = TRUE)

  # Extract relevant data
  data <- response_data$data$target


  # Transform tractability into a readable data frame
  if (!is.null(data$tractability)) {
    tractability <- data$tractability %>%
      bind_rows() %>%
      mutate(gene_id = gene_id, approvedSymbol = data$approvedSymbol, biotype = data$biotype)
    tractability_all <- bind_rows(tractability_all, tractability)
  }
}

# Save combined genetic constraint and tractability data as TSV files
write.table(tractability_all, "tractability.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
