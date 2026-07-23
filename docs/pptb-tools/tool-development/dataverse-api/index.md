---
title: Dataverse API
description: The API surface a PPTB tool uses to read and write Dataverse data.
source: https://docs.powerplatformtoolbox.com/tool-development/api-reference/dataverse-api
last_verified: 2026-07-22
---

# Dataverse API

The Dataverse API (`window.dataverseAPI`) is a complete HTTP client for interacting with Microsoft Dataverse from inside a PPTB tool. It covers CRUD operations, relationship associations, FetchXML and OData queries, entity/attribute/relationship metadata, global option sets, custom action and function execution, and solution deployment. It's the API most PPTB tools spend the majority of their time calling.

**Every method accepts an optional trailing `connectionTarget: 'primary' | 'secondary'` parameter (default `'primary'`), and any metadata change you make — creating or updating an entity, attribute, relationship, or option set — must be followed by a call to `dataverseAPI.publishCustomizations()` before it takes effect in the environment.**

For complete TypeScript definitions, install the `@pptb/types` package:

```bash
npm install --save-dev @pptb/types
```

## CRUD operations

### `dataverseAPI.create(entityLogicalName, record, connectionTarget?)`

Requires v1.0.17

Creates a new record.

**Parameters:** `entityLogicalName: string`, `record: Record<string, unknown>`, `connectionTarget?: 'primary' | 'secondary'`
**Returns:** `Promise<CreateResult>` — the created record ID (`id`) and any returned fields

```typescript
// Create account using primary connection
const accountResult = await dataverseAPI.create('account', {
  name: 'Contoso Ltd',
  telephone1: '555-1234',
  websiteurl: 'https://contoso.com',
})
console.log('Created account:', accountResult.id)

// Create contact using secondary connection
const contactResult = await dataverseAPI.create(
  'contact',
  { firstname: 'Dave' },
  'secondary',
)
```

### `dataverseAPI.retrieve(entityLogicalName, id, columns?, connectionTarget?)`

Requires v1.0.17

Retrieves a single record. Best practice: only retrieve the columns you need.

**Parameters:** `entityLogicalName: string`, `id: string`, `columns?: string[]`, `connectionTarget?: 'primary' | 'secondary'`
**Returns:** `Promise<Record<string, any>>`

```typescript
const account = await dataverseAPI.retrieve('account', accountResult.id, [
  'name',
  'telephone1',
  'emailaddress1',
])
console.log('Account name:', account.name)
```

### `dataverseAPI.update(entityLogicalName, id, record, connectionTarget?)`

Requires v1.0.17

Updates an existing record.

**Parameters:** `entityLogicalName: string`, `id: string`, `record: Record<string, unknown>`, `connectionTarget?: 'primary' | 'secondary'`
**Returns:** `Promise<void>`

```typescript
await dataverseAPI.update('account', accountResult.id, {
  telephone1: '555-5678',
  websiteurl: 'https://www.contoso.com',
})
```

### `dataverseAPI.delete(entityLogicalName, id, connectionTarget?)`

Requires v1.0.17

Deletes a record.

**Parameters:** `entityLogicalName: string`, `id: string`, `connectionTarget?: 'primary' | 'secondary'`
**Returns:** `Promise<void>`

```typescript
await dataverseAPI.delete('account', 'e15a8347-f958-4c20-b964-a8d7105f645f')
```

### `dataverseAPI.createMultiple(entityLogicalName, records, connectionTarget?)`

Requires v1.0.17

Creates multiple records. Each record must include `@odata.type`.

**Returns:** `Promise<string[]>` — created record IDs

```typescript
const results = await dataverseAPI.createMultiple('account', [
  { name: 'Contoso Ltd', '@odata.type': 'Microsoft.Dynamics.CRM.account' },
  { name: 'Fabrikam Inc', '@odata.type': 'Microsoft.Dynamics.CRM.account' },
])
```

### `dataverseAPI.updateMultiple(entityLogicalName, records, connectionTarget?)`

Requires v1.0.17

Updates multiple records. Each record must include an `id` property and `@odata.type`.

**Returns:** `Promise<void>`

```typescript
await dataverseAPI.updateMultiple('account', [
  { accountid: 'guid-1', name: 'Updated Name 1', '@odata.type': 'Microsoft.Dynamics.CRM.account' },
  { accountid: 'guid-2', name: 'Updated Name 2', '@odata.type': 'Microsoft.Dynamics.CRM.account' },
])
```

## Relationship associations

### `dataverseAPI.associate(primaryEntityName, primaryEntityId, relationshipName, relatedEntityName, relatedEntityId, connectionTarget?)`

Requires v1.0.17

Associates two records in a many-to-many relationship.

```typescript
// Assign a security role to a user
await dataverseAPI.associate(
  'systemuser',
  'user-guid-here',
  'systemuserroles_association',
  'role',
  'role-guid-here',
)
```

### `dataverseAPI.disassociate(primaryEntityName, primaryEntityId, relationshipName, relatedEntityId, connectionTarget?)`

Requires v1.0.17

Disassociates two records in a many-to-many relationship.

```typescript
await dataverseAPI.disassociate(
  'systemuser',
  'user-guid-here',
  'systemuserroles_association',
  'role-guid-here',
)
```

## Queries

### `dataverseAPI.fetchXmlQuery(fetchXml, connectionTarget?)`

Requires v1.0.17

Executes a FetchXML query.

**Returns:** `Promise<FetchXmlResult>` — `{ value: Record<string, unknown>[], '@odata.context': string, '@Microsoft.Dynamics.CRM.fetchxmlpagingcookie'?: string }`

```typescript
const fetchXml = `
  <fetch top="10">
    <entity name="account">
      <attribute name="name" />
      <attribute name="accountid" />
      <filter>
        <condition attribute="statecode" operator="eq" value="0" />
      </filter>
      <order attribute="name" />
    </entity>
  </fetch>
`

const result = await dataverseAPI.fetchXmlQuery(fetchXml)
result.value.forEach((account) => console.log('Account:', account.name))
```

### `dataverseAPI.retrieveMultiple(fetchXml, connectionTarget?)`

Requires v1.0.17

Alias of `fetchXmlQuery()`, kept for backward compatibility.

### `dataverseAPI.queryData(odataQuery, connectionTarget?)`

Requires v1.0.17

Retrieves multiple records using an OData query string (`$select`, `$filter`, `$orderby`, `$top`, `$skip`, `$expand`).

**Returns:** `Promise<{ value: Record<string, unknown>[] }>`

```typescript
const result = await dataverseAPI.queryData(
  'accounts?$select=name,emailaddress1,telephone1&$filter=statecode eq 0&$orderby=name&$top=10',
)

// Query with expand to include related records
const expanded = await dataverseAPI.queryData(
  'accounts?$select=name,accountid&$expand=contact_customer_accounts($select=fullname,emailaddress1)&$top=5',
)
```

## Metadata

### `dataverseAPI.getEntityMetadata(entityLogicalName, searchByLogicalName, entityProperties?, connectionTarget?)`

Requires v1.0.17

**Parameters:** `entityLogicalName: string` (logical name or metadata ID), `searchByLogicalName: boolean`, `entityProperties?: string[]`, `connectionTarget?`
**Returns:** `Promise<EntityMetadata>`

```typescript
const metadata = await dataverseAPI.getEntityMetadata('account', true, [
  'LogicalName',
  'DisplayName',
  'EntitySetName',
])
console.log('Display Name:', metadata.DisplayName?.LocalizedLabels[0]?.Label)
```

### `dataverseAPI.getEntityRelatedMetadata(entityLogicalName, relatedPath, relatedProperties?, connectionTarget?)`

Requires v1.0.17

Gets related metadata for an entity (attributes, relationships, and so on). `relatedPath` is the path after `EntityDefinitions(LogicalName='name')` — supports collections and specific records, for example `Attributes`, `Keys`, `ManyToOneRelationships`, `Attributes(LogicalName='name')`, `Attributes(LogicalName='industrycode')/OptionSet`.

**Returns:** `Promise<EntityRelatedMetadataResponse<P>>` — either a collection (`{ value: [...] }`) or a single metadata object, depending on `relatedPath`.

```typescript
// Get all attributes for an entity
const attributes = await dataverseAPI.getEntityRelatedMetadata('account', 'Attributes')

// Get a single attribute definition (returns an object, not a collection)
const nameAttribute = await dataverseAPI.getEntityRelatedMetadata(
  'account',
  "Attributes(LogicalName='name')",
)
```

### `dataverseAPI.getAllEntitiesMetadata(entityProperties?, connectionTarget?)`

Requires v1.0.17

Gets metadata for all entities (defaults to `LogicalName`, `DisplayName`, `MetadataId` if `entityProperties` is omitted).

**Returns:** `Promise<{ value: any[] }>`

### `dataverseAPI.getEntitySetName(logicalName)`

Requires v1.0.17

Gets the entity set (collection) name for a logical name. No `connectionTarget` needed. Works for most scenarios, but custom entities with non-standard pluralization may require retrieving full metadata instead.

```typescript
const tableSetName = await dataverseAPI.getEntitySetName('contact')
console.log(tableSetName) // Outputs: contacts
```

## CSDL metadata document

### `dataverseAPI.getCSDLDocument(connectionTarget?)`

Requires v1.0.20

Retrieves the complete CSDL/EDMX metadata document for the Dataverse environment — the full OData service document as raw XML, covering every entity, action, function, and complex type. The response is gzip-compressed in transit and decompressed transparently.

**Returns:** `Promise<string>` — raw CSDL/EDMX XML (typically 1–5MB)

The document includes `EntityType`, `Property`, `NavigationProperty`, `ComplexType`, `EnumType`, `Action`, `Function`, and `EntityContainer` elements. Parse it with `DOMParser` and `querySelectorAll` to enumerate custom actions/functions or inspect entity shapes:

```typescript
const csdlXml = await dataverseAPI.getCSDLDocument()
const parser = new DOMParser()
const xmlDoc = parser.parseFromString(csdlXml, 'text/xml')

// Extract all custom actions
const actions = xmlDoc.querySelectorAll('Action')
actions.forEach((action) => {
  const actionName = action.getAttribute('Name')
  const isBound = action.getAttribute('IsBound') === 'true'
  console.log(`- ${actionName} (${isBound ? 'Bound' : 'Unbound'})`)
})
```

> **Pro tip:** The CSDL document is large (1–5MB). Cache it if you need to reference it multiple times, or use `getEntityMetadata()` / `getEntityRelatedMetadata()` for targeted queries instead. The document uses XML namespaces — simple element-name `querySelectorAll()` calls work for the common cases shown here, but more complex queries may need namespace-aware parsing.

### `dataverseAPI.getSolutions(selectColumns, connectionTarget?)`

Requires v1.0.17

Gets solutions from the environment. `selectColumns` is required and must contain at least one column.

```typescript
const solutions = await dataverseAPI.getSolutions([
  'solutionid',
  'uniquename',
  'friendlyname',
  'version',
  'ismanaged',
])
```

## Helper methods

PPTB provides comprehensive metadata operations to programmatically create, read, update, and delete Dataverse schema elements — entities, attributes, relationships, and option sets.

> **Important:** Always call `dataverseAPI.publishCustomizations()` after making metadata changes to apply them to your environment.

### `dataverseAPI.buildLabel(text, languageCode?)`

Requires v1.0.20

Builds a properly formatted `Label` object for metadata operations. `languageCode` defaults to 1033 (English).

```typescript
const label = dataverseAPI.buildLabel('Customer Name')
const labelFrench = dataverseAPI.buildLabel('Nom du client', 1036)
```

### `dataverseAPI.getAttributeODataType(attributeType)`

Requires v1.0.20

Gets the OData type name for a given `AttributeMetadataType` enum value — useful when building attribute definitions.

```typescript
const odataType = dataverseAPI.getAttributeODataType(
  DataverseAPI.AttributeMetadataType.String,
)
console.log(odataType) // "Microsoft.Dynamics.CRM.StringAttributeMetadata"
```

## Entity operations

### `dataverseAPI.createEntityDefinition(entityDefinition, options?, connectionTarget?)`

Requires v1.0.20

Creates a new entity (table). `options` can include `{ solutionUniqueName: "MySolution" }`.

**Returns:** `Promise<{ id: string }>`

```typescript
const newEntity = await dataverseAPI.createEntityDefinition(
  {
    '@odata.type': 'Microsoft.Dynamics.CRM.EntityMetadata',
    LogicalName: 'new_project',
    DisplayName: dataverseAPI.buildLabel('Project'),
    DisplayCollectionName: dataverseAPI.buildLabel('Projects'),
    OwnershipType: 'UserOwned', // UserOwned, TeamOwned, OrganizationOwned, None
    IsActivity: false,
    HasActivities: true,
    HasNotes: true,
    Attributes: [
      {
        '@odata.type': 'Microsoft.Dynamics.CRM.StringAttributeMetadata',
        SchemaName: 'new_Name',
        DisplayName: dataverseAPI.buildLabel('Project Name'),
        RequiredLevel: { Value: 'ApplicationRequired' },
        MaxLength: 100,
        FormatName: { Value: 'Text' },
      },
    ],
  },
  { solutionUniqueName: 'MyCustomSolution' },
)

await dataverseAPI.publishCustomizations('new_project')
```

### `dataverseAPI.updateEntityDefinition(entityIdentifier, entityDefinition, options?, connectionTarget?)`

Requires v1.0.20

Updates an existing entity's metadata. `entityIdentifier` is a MetadataId or LogicalName; `options` can include `{ mergeLabels: true }`.

### `dataverseAPI.deleteEntityDefinition(entityIdentifier, connectionTarget?)`

Requires v1.0.20

Deletes an entity — permanent, and no need to publish afterward, since deletion takes effect immediately.

## Attribute operations

### `dataverseAPI.createAttribute(entityLogicalName, attributeDefinition, options?, connectionTarget?)`

Requires v1.0.20

Creates a new attribute (column) on an entity. Combine with `getAttributeODataType()` and `AttributeMetadataType` to build the definition for text, whole number, decimal, date, choice (option set), and lookup fields:

```typescript
// Create a choice (option set) field - local
const choiceAttribute = await dataverseAPI.createAttribute('new_project', {
  '@odata.type': dataverseAPI.getAttributeODataType(
    DataverseAPI.AttributeMetadataType.Picklist,
  ),
  SchemaName: 'new_Priority',
  DisplayName: dataverseAPI.buildLabel('Priority'),
  RequiredLevel: { Value: 'ApplicationRequired' },
  OptionSet: {
    '@odata.type': 'Microsoft.Dynamics.CRM.OptionSetMetadata',
    IsGlobal: false,
    OptionSetType: 'Picklist',
    Options: [
      { Value: 1, Label: dataverseAPI.buildLabel('Low') },
      { Value: 2, Label: dataverseAPI.buildLabel('Medium') },
      { Value: 3, Label: dataverseAPI.buildLabel('High') },
    ],
  },
})

// Create a lookup field (single entity)
const lookupAttribute = await dataverseAPI.createAttribute('new_project', {
  '@odata.type': dataverseAPI.getAttributeODataType(
    DataverseAPI.AttributeMetadataType.Lookup,
  ),
  SchemaName: 'new_AccountId',
  DisplayName: dataverseAPI.buildLabel('Account'),
  RequiredLevel: { Value: 'None' },
  Targets: ['account'], // Entity types this lookup can reference
})

await dataverseAPI.publishCustomizations('new_project')
```

### `dataverseAPI.updateAttribute(entityLogicalName, attributeIdentifier, attributeDefinition, options?, connectionTarget?)`

Requires v1.0.20

Updates an existing attribute's metadata.

### `dataverseAPI.deleteAttribute(entityLogicalName, attributeIdentifier, connectionTarget?)`

Requires v1.0.20

Deletes an attribute — permanent. Follow with `publishCustomizations()` to complete the deletion.

## Polymorphic lookup attributes

### `dataverseAPI.createPolymorphicLookupAttribute(entityLogicalName, attributeDefinition, options?, connectionTarget?)`

Requires v1.0.20

Creates a polymorphic lookup that can reference multiple entity types (for example, a Customer field that can reference both Account and Contact).

**Returns:** `Promise<{ AttributeId: string }>`

```typescript
const customerLookup = await dataverseAPI.createPolymorphicLookupAttribute(
  'new_order',
  {
    SchemaName: 'new_CustomerId',
    DisplayName: dataverseAPI.buildLabel('Customer'),
    RequiredLevel: { Value: 'ApplicationRequired' },
    Targets: ['account', 'contact'], // Can reference both entities
  },
)

await dataverseAPI.publishCustomizations()
```

> **Alternative:** For customer lookups specifically, the `CreateCustomerRelationships` action (via `dataverseAPI.execute()`) creates both the lookup and relationships in a single operation.

## Relationship operations

### `dataverseAPI.createRelationship(relationshipDefinition, options?, connectionTarget?)`

Requires v1.0.18

Creates a new 1:N or N:N relationship.

```typescript
// One-to-Many: Account (1) -> Projects (N)
const oneToManyRelationship = await dataverseAPI.createRelationship({
  '@odata.type': 'Microsoft.Dynamics.CRM.OneToManyRelationshipMetadata',
  SchemaName: 'new_account_project',
  ReferencedEntity: 'account',
  ReferencedAttribute: 'accountid',
  ReferencingEntity: 'new_project',
  Lookup: {
    '@odata.type': dataverseAPI.getAttributeODataType(
      DataverseAPI.AttributeMetadataType.Lookup,
    ),
    SchemaName: 'new_AccountId',
    DisplayName: dataverseAPI.buildLabel('Account'),
    RequiredLevel: { Value: 'None' },
  },
  CascadeConfiguration: {
    Assign: 'NoCascade',
    Delete: 'RemoveLink', // Cascade, RemoveLink, Restrict
    Merge: 'NoCascade',
    Reparent: 'NoCascade',
    Share: 'NoCascade',
    Unshare: 'NoCascade',
  },
})

await dataverseAPI.publishCustomizations()
```

### `dataverseAPI.updateRelationship(relationshipIdentifier, relationshipDefinition, options?, connectionTarget?)`

Requires v1.0.18

Updates an existing relationship's metadata (for example, cascade configuration).

### `dataverseAPI.deleteRelationship(relationshipIdentifier, connectionTarget?)`

Requires v1.0.18

Deletes a relationship — permanent.

## Global option sets

### `dataverseAPI.createGlobalOptionSet(optionSetDefinition, options?, connectionTarget?)`

Requires v1.0.20

Creates a new global option set (choice) shareable across multiple entities.

```typescript
const globalOptionSet = await dataverseAPI.createGlobalOptionSet(
  {
    '@odata.type': 'Microsoft.Dynamics.CRM.OptionSetMetadata',
    Name: 'new_projectstatus',
    DisplayName: dataverseAPI.buildLabel('Project Status'),
    OptionSetType: 'Picklist',
    IsGlobal: true,
    Options: [
      { Value: 1, Label: dataverseAPI.buildLabel('Planning') },
      { Value: 2, Label: dataverseAPI.buildLabel('In Progress') },
      { Value: 3, Label: dataverseAPI.buildLabel('On Hold') },
      { Value: 4, Label: dataverseAPI.buildLabel('Completed') },
      { Value: 5, Label: dataverseAPI.buildLabel('Cancelled') },
    ],
  },
  { solutionUniqueName: 'MyCustomSolution' },
)

await dataverseAPI.publishCustomizations()
```

### `dataverseAPI.updateGlobalOptionSet(optionSetIdentifier, optionSetDefinition, options?, connectionTarget?)`

Requires v1.0.20

Updates an existing global option set.

### `dataverseAPI.deleteGlobalOptionSet(optionSetIdentifier, connectionTarget?)`

Requires v1.0.20

Deletes a global option set — permanent.

## Option value operations

### `dataverseAPI.insertOptionValue(params, connectionTarget?)`

Requires v1.0.20

Inserts a new option value into a local or global option set. `params` takes either `{ EntityLogicalName, AttributeLogicalName }` (local) or `{ OptionSetName }` (global), plus `Value: number`, `Label: Label`, and optional `Description: Label`.

```typescript
// Add option to a global option set
await dataverseAPI.insertOptionValue({
  OptionSetName: 'new_projectstatus',
  Value: 6,
  Label: dataverseAPI.buildLabel('Archived'),
})

await dataverseAPI.publishCustomizations()
```

> **Status columns:** For status choice columns (`statuscode`), use the `InsertStatusValue` action via `dataverseAPI.execute()` instead — it requires a `StateCode` parameter.

### `dataverseAPI.updateOptionValue(params, connectionTarget?)`

Requires v1.0.20

Updates an existing option value. `params` adds `Label?`, `Description?`, and `MergeLabels?: boolean` to the same local/global shape.

### `dataverseAPI.deleteOptionValue(params, connectionTarget?)`

Requires v1.0.20

Deletes an option value from an option set.

### `dataverseAPI.orderOption(params, connectionTarget?)`

Requires v1.0.20

Reorders option values in an option set via `params.Values: number[]` — an array of values in the desired order.

```typescript
await dataverseAPI.orderOption({
  EntityLogicalName: 'new_project',
  AttributeLogicalName: 'new_priority',
  Values: [3, 2, 1], // High, Medium, Low
})

await dataverseAPI.publishCustomizations()
```

## Actions & functions

### `dataverseAPI.execute(request, connectionTarget?)`

Requires v1.0.17

Executes a custom action or function through a unified interface. Supports both bound (entity-specific) and unbound (global) operations.

**Parameters:** `request.entityName?`, `request.entityId?` (required for bound operations), `request.operationName: string`, `request.operationType: 'action' | 'function'`, `request.parameters?: Record<string, unknown>`
**Returns:** `Promise<Record<string, unknown>>`

```typescript
// Bound action - operates on a specific entity record
const boundResult = await dataverseAPI.execute({
  entityName: 'systemuser',
  entityId: 'user-guid',
  operationName: 'SetBusinessSystemUser',
  operationType: 'action',
  parameters: {
    BusinessUnit: 'businessunits(bu-guid)',
    ReassignPrincipal: 'systemusers(user-guid)',
    DoNotMoveAllRecords: true,
  },
})

// Unbound function - global operation
const unboundResult = await dataverseAPI.execute({
  operationName: 'WhoAmI',
  operationType: 'function',
})
```

## Customizations

### `dataverseAPI.publishCustomizations(tableLogicalName?, connectionTarget?)`

Requires v1.0.17

Publishes customizations for the current environment. If `tableLogicalName` is omitted, all pending customizations are published.

```typescript
// Publish all customizations for the primary connection
await dataverseAPI.publishCustomizations()

// Publish only the account table customizations for the secondary connection
await dataverseAPI.publishCustomizations('account', 'secondary')
```

### `dataverseAPI.deploySolution(solutionContent, options?, connectionTarget?)`

Requires v1.0.17

Deploys (imports) a Dataverse solution. `solutionContent` is a base64 solution zip or binary data. `options` may include `importJobId`, `publishWorkflows`, `overwriteUnmanagedCustomizations`, `skipProductUpdateDependencies`, and `convertToManaged`.

**Returns:** `Promise<{ ImportJobId: string }>`

```typescript
const solutionFile = await toolboxAPI.fileSystem.readBinary('/path/to/solution.zip')

const result = await dataverseAPI.deploySolution(solutionFile, {
  publishWorkflows: true,
  overwriteUnmanagedCustomizations: false,
})

console.log('Solution deployment started. Import Job ID:', result.ImportJobId)
```

### `dataverseAPI.getImportJobStatus(importJobId, connectionTarget?)`

Requires v1.0.17

Gets the status of a solution import job started by `deploySolution()`.

```typescript
const status = await dataverseAPI.getImportJobStatus(result.ImportJobId)
console.log('Import status:', status)
```

## Checklist

- [ ] `retrieve()` and `getEntityRelatedMetadata()` calls request only the columns/properties actually needed.
- [ ] `createMultiple()` / `updateMultiple()` records include `@odata.type` (and `id` for updates).
- [ ] Every metadata-modifying call (`createEntityDefinition`, `createAttribute`, `createRelationship`, `createGlobalOptionSet`, option value operations, and their update/delete counterparts) is followed by `dataverseAPI.publishCustomizations()`.
- [ ] Multi-connection tools pass `'secondary'` explicitly where the secondary environment is intended.
- [ ] Solution imports poll `getImportJobStatus()` until the job completes rather than assuming success.

## Related links

- [Dataverse API (source)](https://docs.powerplatformtoolbox.com/tool-development/api-reference/dataverse-api)
- [Overview](/pptb-tools/tool-development/)
- [API Reference](/pptb-tools/tool-development/api-reference/)
- [ToolBox API](/pptb-tools/tool-development/toolbox-api/)
- [PowerPlatform API](/pptb-tools/tool-development/powerplatform-api/)
