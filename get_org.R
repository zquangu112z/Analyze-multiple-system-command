library(RPostgreSQL)
library(stringr)

# Enter the values for you database connection
dsn_database = "db_name"      
dsn_hostname = "hostname.us-east-1.redshift.amazonaws.com"     
dsn_port = "5439"              
dsn_uid = "user"        
dsn_pwd = "UEz$oW8TDi3"     

# Create the database connection
tryCatch({
  drv <- dbDriver("PostgreSQL")
  print("Connecting to database")
  conn <- dbConnect(drv, 
                    dbname = dsn_database,
                    host = dsn_hostname, 
                    port = dsn_port,
                    user = dsn_uid, 
                    password = dsn_pwd)
  print("Connected!")
},
error=function(cond) {
  print("Unable to connect to database.")
})

# List tables existing in the database 'northwind'
cursor <- dbGetQuery(conn, "SELECT nspname
                     FROM pg_catalog.pg_namespace")
print(cursor)
ret <- NULL
for (name in cursor[[1]]){
  # print(name)
  if(grepl("org_", name, fixed = TRUE)){
    name <- strsplit(name, "rg_")[[1]][2]
    ret <- append(ret,name)
  }else{
    # print("hihi")
  }
}
# Close the database connection
dbDisconnect(conn)
