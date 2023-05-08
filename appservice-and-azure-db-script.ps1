# Connect an App Service app to SQL Database
# Variables
$location="East US"
$resourceGroup="cli-demo-rg"
$tag="connecting-to-sql.sh"
$appServicePlan="azure-cli-service-plan"
$webapp="azure-cli-web-app"
$server="my-cli-server"
$database="my-demo-db"
$login="azureuser"
$password="Pa$$w0rD12345"
$startIp="0.0.0.0"
$endIp="0.0.0.0"

# Create a resource group.
echo "Creating $resourceGroup in "$location"..."
az group create --name $resourceGroup --location "$location" --tag $tag

# Create an App Service Plan
echo "Creating $appServicePlan"
az appservice plan create --name $appServicePlan --resource-group $resourceGroup --location "$location"

# Create a Web App
echo "Creating $webapp"
az webapp create --name $webapp --plan $appServicePlan --resource-group $resourceGroup 

# Create a SQL Database server
echo "Creating $server"
az sql server create --name $server --resource-group $resourceGroup --location "$location" --admin-user $login --admin-password $password

# Configure firewall for Azure access
echo "Creating firewall rule with starting ip of $startIp" and ending ip of $endIp
az sql server firewall-rule create --server $server --resource-group $resourceGroup --name AllowYourIp --start-ip-address $startIp --end-ip-address $endIp

# Create a database called 'MySampleDatabase' on server
echo "Creating $database"
az sql db create --server $server --resource-group $resourceGroup --name $database --service-objective S0

# Get connection string for the database
$connstring=$(az sql db show-connection-string --name $database --server $server --client ado.net --output tsv)

# Add credentials to connection string
$connstring=${connstring//<username>/$login}
$connstring=${connstring//<password>/$password}

# Assign the connection string to an app setting in the web app
az webapp config appsettings set --name $webapp --resource-group $resourceGroup --settings "SQLSRV_CONNSTR=$connstring"