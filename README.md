# Fabric Portal – Preparation Deployment Guide
For a more comprehensive guide that contains pictures please refer to the "Portal for Fabric - Preparation Deployment Guide" PDF file in this repository.

> **Owner**: Ingraphic AS  
> **Last updated**: March 17, 2025

## Table of Contents
- [Introduction](#introduction)
- [Roles Required](#roles-required)
- [Preparation Checklist](#preparation-checklist)
- [Deployment Steps](#deployment-steps)
  - [Azure Subscription](#azure-subscription)
  - [Microsoft Entra Configuration](#microsoft-entra-configuration)
  - [Entra Groups Configuration](#entra-groups-configuration)
  - [SQL Configuration](#sql-configuration)
  - [Service Principals](#service-principals)
  - [Fabric Configuration](#fabric-configuration)
- [Post Deployment Steps](#post-deployment-steps)
- [Troubleshooting](#troubleshooting)

## Introduction

This guide is for technical resources responsible for creating the resources needed to deploy the "Portal for Microsoft Fabric" in Microsoft Azure.

The "Portal for Microsoft Fabric" will create the following resources during deployment:

| Resource | Description |
|----------|-------------|
| Log Analytics Workspace | Collect, analyze and query logs from various Azure services and applications |
| Application Insights | Monitoring service that provides real-time performance metrics and analytics |
| Automation Account | Enables process automation through runbooks for managing Fabric Capacity schedules |
| Runbooks | Workflow scripts in PowerShell that automate Fabric Capacity start up and pause times |
| Storage Account | Storage for data objects including company logos, report images and application settings |
| SQL Server and Database | Relational database that stores user, group, report data and references |
| Logic App | Low code workflow automation for sending invite emails to external users or customers |
| Key Vault | Secure storage for keys, secrets and credentials used by Container Applications |
| Container Apps Environment | Managed hosting environment for containerized applications |
| Container Instance | Serverless container service that initializes the database and workspace |
| Container Apps | Managed serverless platform - main components of the frontend and backend |

## Roles Required

| Role | Description |
|------|-------------|
| Entra Administrator | Create Entra groups and assign users |
| Entra Application Developer | Create Service Principals and add permissions |
| Fabric Administrator | Configure Fabric settings required for the portal |
| Owner role for Subscription | **IMPORTANT**: Only a user with Owner role at the Subscription level can successfully deploy from Azure Marketplace |

## Preparation Checklist

High-level checklist of required steps:

1. **Entra Primary Domain** - Used by the Portal Application 
2. **Entra Groups** - Create Users, Admins, Fabric Admins groups
3. **Entra Application Registrations** - Create WEB, SPA and Fabric Service Principals
4. **Fabric Capacity** - Set up capacity for workspaces, reports and dashboards

## Deployment Steps

### Azure Subscription

Ensure you have a valid Microsoft Azure subscription for the Portal for Fabric Deployment. The Managed Application and resources will be deployed to this subscription.

#### Resource Group
Create a resource group to contain the Managed Application resource. This resource group will only contain the Managed Application. All other resources will be deployed to a separate Managed Resource Group.

**Recommended name**: rg-manapp-storage

### Microsoft Entra Configuration

#### Primary Domain Name
The primary domain name is needed during deployment. 
- Go to Azure Portal → Microsoft Entra ID to find the Primary Domain field

### Entra Groups Configuration

Create the following security groups:

| Group Name | Description | Suggested Name |
|------------|-------------|----------------|
| Portal User Group | Allows access to the Portal as a user with limited permissions | SG_APP_{Company Standard}_Portal_Users |
| Portal Admin Group | Allows access as admin with privileged permissions | SG_APP_{Company Standard}_Portal_Admins |
| Fabric Workspace Admin Group | Access to all workspaces created in the Portal | SG_APP_{Company Standard}_Portal_FabricAdmins |

Steps:
1. Go to Azure Portal → Microsoft Entra ID → Groups → Add New Group
2. Create the required groups 
3. Assign users to the groups

### SQL Configuration

#### SQL Server Administrator
Used for basic authentication to the database.

**Username requirements**:
- May contain lowercase and uppercase letters and numbers
- Must NOT start with numbers or symbols

**Password requirements**:
- At least 8 characters, maximum 128 characters
- Must contain uppercase and lowercase letters, numbers and symbols

#### SQL Server Entra Administrator (optional)
Configure the SQL Server to accept Administrator logins using Entra Authentication.

#### Office IP Address (Optional)
Required for manual access to the SQL database by Administrator. This step is optional.

### Service Principals

#### 1. Web Service Principal
Create Entra Application for back-end.

Steps:
1. Go to Azure Portal → Microsoft Entra ID → App Registrations → "New Registration"
2. Name: `SP_Portal_WEB` (or your preferred name)
3. Create a client secret with 730 days expiration
4. Add the following Microsoft Graph Application permissions:
   - Application.ReadWrite.All
   - Group.Create
   - Group.ReadWrite.All
   - User.Invite.All
   - User.Read
   - User.ReadWrite.All
5. Grant admin consent
6. Add a scope named "access_as_user"

#### 2. SPA Service Principal
Create Entra Application for front-end.

Steps:
1. Go to Azure Portal → Microsoft Entra ID → App Registrations → "New Registration"
2. Name: `SP_Portal_SPA`
3. Add the following permissions: 
   - Microsoft Graph: email, offline_access, openid, profile, User.Read
   - SP_Portal_WEB: access_as_user
4. Grant admin consent

#### 3. Fabric Service Principal
Create Entra Application for Fabric API Access.

Steps:
1. Go to Azure Portal → Microsoft Entra ID → App Registrations → "New Registration"
2. Name: `SP_Portal_Fabric`
3. Create a client secret with 730 days expiration
4. Add the following PowerBI Delegated permissions:
   - Capacity.ReadWrite.All
   - Dashboard.ReadWrite.All
   - Dataset.ReadWrite.All
   - PaginatedReport.ReadWrite.All
   - Report.ReadWrite.All
   - Workspace.ReadWrite.All
5. Grant admin consent
6. Add this Service Principal to the SG_APP_Portal_FabricAdmins Entra Group

#### 4. Retrieve Enterprise Application Object IDs
Get the Object IDs for SP_Portal_WEB and SP_Portal_Fabric:
1. Go to Microsoft Entra ID → Enterprise applications
2. Search for the service principals and copy their Object IDs

### Fabric Configuration

Configure Microsoft Fabric to allow service principals to work with the portal:

1. In Fabric, go to Settings → Admin portal → Tenant settings
2. Enable the following settings:
   - Microsoft Fabric: "Users can create Fabric items"
   - Workspace settings: "Create workspaces"
   - Developer settings: "Service principals can use Fabric APIs"

If using an existing Fabric Capacity:
1. Add SP_Portal_Fabric service principal as Capacity Administrator to your Fabric Capacity
2. Provide the Capacity resource name during deployment

## Post Deployment Steps

### Logic App for Email Invitations
Authenticate the Logic App to send email invitations:
1. Go to the API connection resource called "office 365"
2. Navigate to General → Edit API connection → Authorize
3. Authenticate with the email address you want emails to be sent from
4. Save the connection

## Troubleshooting

### Deployment Fails
- Check error messages in the deployment
- Verify you have Owner permissions at the Subscription level

### Successful Deployment but Application Does Not Work
1. Check the Container Instance named "initialization-container"
2. Go to Settings → Containers → Logs 
3. Review error messages
4. Common issues:
   - Permissions not correctly set
   - Fabric not configured correctly

For assistance, contact: portalsupport@ingraphic.no
