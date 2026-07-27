---
name: add-dataverse-api
description: Wires up `window.dataverseAPI` calls — CRUD, relationship associations, FetchXML/OData queries, entity/attribute/relationship/option-set metadata and schema writes, custom action/function execution, and solution deployment — into an existing PPTB tool's code. Use when asked to "create/retrieve/update/delete a Dataverse record", "run a FetchXML query", "run an OData query", "create a custom table with these columns", "add a choice/lookup field or relationship", "call this custom action/function", "deploy this solution zip", or "get metadata for this entity".
---

# Add Dataverse API

The Dataverse API (`window.dataverseAPI`) is a complete HTTP client for Microsoft Dataverse from inside a PPTB tool — CRUD, relationship associations, FetchXML/OData queries, entity/attribute/relationship/option-set metadata and schema changes, custom action/function execution, and solution deployment. It's the API most PPTB tools spend the majority of their time calling. This skill wires the right `dataverseAPI` calls in for the operation the tool needs.

**Every method accepts an optional trailing `connectionTarget: 'primary' | 'secondary'` (default `'primary'`) — pass `'secondary'` explicitly for multi-connection tools targeting the second environment. And any metadata change — creating or updating an entity, attribute, relationship, or option set — must be followed by `dataverseAPI.publishCustomizations()`, since it doesn't take effect in the environment until published.**

## Step 0: Prerequisites

Confirm `@pptb/types` is in `devDependencies` (`npm install --save-dev @pptb/types` if not) — it provides every type referenced below (`CreateResult`, `FetchXmlResult`, `EntityMetadata`, `AttributeMetadataType`, etc.).

## Step 1: Identify which operation category is needed

| Category | Covers | Go to |
| --- | --- | --- |
| CRUD | Create/read/update/delete single or multiple records | Step 2 |
| Relationship associations | Many-to-many associate/disassociate | Step 3 |
| Queries | FetchXML, OData | Step 4 |
| Metadata reads | Entity/attribute/relationship metadata, CSDL document, solutions | Step 5 |
| Schema writes | Create/update/delete entities, attributes, relationships, global option sets, option values | Step 6 |
| Actions & functions | Custom bound/unbound operations | Step 7 |
| Solution deployment | Import a solution zip and track the job | Step 8 |

## Step 2: CRUD operations

All require v1.0.17. Only request the columns actually needed on `retrieve()` — Dataverse charges no less for over-fetching, but it does make the tool slower and the code harder to reason about.

```typescript
const accountResult = await dataverseAPI.create('account', {
  name: 'Contoso Ltd',
  telephone1: '555-1234',
})
// accountResult: CreateResult — accountResult.id is the new record's GUID

const account = await dataverseAPI.retrieve('account', accountResult.id, [
  'name',
  'telephone1',
  'emailaddress1',
])

await dataverseAPI.update('account', accountResult.id, { telephone1: '555-5678' })
await dataverseAPI.delete('account', accountResult.id)
```

For bulk writes, use `createMultiple(entityLogicalName, records, connectionTarget?)` / `updateMultiple(entityLogicalName, records, connectionTarget?)` instead of looping individual calls — but every record needs `@odata.type`, and `updateMultiple` records also need an `id`:

```typescript
await dataverseAPI.createMultiple('account', [
  { name: 'Contoso Ltd', '@odata.type': 'Microsoft.Dynamics.CRM.account' },
  { name: 'Fabrikam Inc', '@odata.type': 'Microsoft.Dynamics.CRM.account' },
])

await dataverseAPI.updateMultiple('account', [
  { accountid: 'guid-1', name: 'Updated Name 1', '@odata.type': 'Microsoft.Dynamics.CRM.account' },
])
```

## Step 3: Relationship associations

`dataverseAPI.associate(primaryEntityName, primaryEntityId, relationshipName, relatedEntityName, relatedEntityId, connectionTarget?)` and the matching `.disassociate(primaryEntityName, primaryEntityId, relationshipName, relatedEntityId, connectionTarget?)` (both v1.0.17) link/unlink two records in a many-to-many relationship — e.g. assigning a security role to a user:

```typescript
await dataverseAPI.associate('systemuser', 'user-guid', 'systemuserroles_association', 'role', 'role-guid')
```

## Step 4: Queries

`fetchXmlQuery(fetchXml, connectionTarget?)` (v1.0.17) runs FetchXML and returns `Promise<FetchXmlResult>` (`{ value, '@odata.context', '@Microsoft.Dynamics.CRM.fetchxmlpagingcookie'? }`). `retrieveMultiple()` is an alias kept for backward compatibility — write new code against `fetchXmlQuery()`.

```typescript
const result = await dataverseAPI.fetchXmlQuery(`
  <fetch top="10">
    <entity name="account">
      <attribute name="name" />
      <filter><condition attribute="statecode" operator="eq" value="0" /></filter>
      <order attribute="name" />
    </entity>
  </fetch>
`)
result.value.forEach((account) => console.log(account.name))
```

`queryData(odataQuery, connectionTarget?)` (v1.0.17) runs an OData query string (`$select`, `$filter`, `$orderby`, `$top`, `$skip`, `$expand`) and returns `Promise<{ value: Record<string, unknown>[] }>`:

```typescript
const result = await dataverseAPI.queryData(
  'accounts?$select=name,emailaddress1&$filter=statecode eq 0&$orderby=name&$top=10',
)
```

Prefer FetchXML for complex aggregation/linked-entity filters; prefer OData for simple, readable `$select`/`$filter`/`$expand` queries.

## Step 5: Metadata reads

- `getEntityMetadata(entityLogicalName, searchByLogicalName, entityProperties?, connectionTarget?)` (v1.0.17) — pass `searchByLogicalName: true` when passing a logical name rather than a metadata ID.
- `getEntityRelatedMetadata(entityLogicalName, relatedPath, relatedProperties?, connectionTarget?)` (v1.0.17) — `relatedPath` is the segment after `EntityDefinitions(LogicalName='name')`, e.g. `Attributes`, `ManyToOneRelationships`, `"Attributes(LogicalName='industrycode')/OptionSet"`. Returns a collection (`{ value: [...] }`) for a collection path, or a single object for a specific-record path.
- `getAllEntitiesMetadata(entityProperties?, connectionTarget?)` (v1.0.17) — defaults to `LogicalName`, `DisplayName`, `MetadataId` when `entityProperties` is omitted.
- `getEntitySetName(logicalName)` (v1.0.17) — no `connectionTarget`; works for standard pluralization, but custom entities with non-standard pluralization may need full metadata instead.
- `getCSDLDocument(connectionTarget?)` (v1.0.20) — the full CSDL/EDMX document (1–5MB, gzip-compressed in transit, decompressed transparently) as raw XML. Only reach for this to enumerate custom actions/functions or inspect shapes that `getEntityMetadata`/`getEntityRelatedMetadata` can't target directly — parse with `DOMParser`, cache the result if referenced more than once, and be aware simple element-name `querySelectorAll()` only covers the common cases (XML namespaces exist in the document).
- `getSolutions(selectColumns, connectionTarget?)` (v1.0.17) — `selectColumns` is required and must contain at least one column.

```typescript
const metadata = await dataverseAPI.getEntityMetadata('account', true, ['LogicalName', 'DisplayName'])
const csdlXml = await dataverseAPI.getCSDLDocument()
const actions = new DOMParser().parseFromString(csdlXml, 'text/xml').querySelectorAll('Action')
```

## Step 6: Schema writes (entities, attributes, relationships, option sets)

> **Always follow a metadata-modifying call with `dataverseAPI.publishCustomizations(tableLogicalName?, connectionTarget?)`** — omit `tableLogicalName` to publish everything pending. `deleteEntityDefinition` is the one documented exception: entity deletion takes effect immediately and needs no publish call. `deleteAttribute` is the opposite — it explicitly still needs a follow-up `publishCustomizations()` to complete. Where a delete method's own behavior isn't explicit (`deleteRelationship`, `deleteGlobalOptionSet`, `deleteOptionValue`), publish afterward anyway — it's a no-op if not needed, and skipping it risks a customization that looks deleted but isn't fully applied.

Build every `Label`/`DisplayName` with `dataverseAPI.buildLabel(text, languageCode?)` (v1.0.20, defaults to 1033/English), and every attribute's `@odata.type` with `dataverseAPI.getAttributeODataType(attributeType)` (v1.0.20) against the `DataverseAPI.AttributeMetadataType` enum, rather than hand-typing either.

**Entities** (v1.0.20): `createEntityDefinition(entityDefinition, options?, connectionTarget?)` (`options` can include `{ solutionUniqueName }`, returns `{ id }`), `updateEntityDefinition(entityIdentifier, entityDefinition, options?, connectionTarget?)` (`options` can include `{ mergeLabels: true }`), `deleteEntityDefinition(entityIdentifier, connectionTarget?)`.

```typescript
const newEntity = await dataverseAPI.createEntityDefinition(
  {
    '@odata.type': 'Microsoft.Dynamics.CRM.EntityMetadata',
    LogicalName: 'new_project',
    DisplayName: dataverseAPI.buildLabel('Project'),
    DisplayCollectionName: dataverseAPI.buildLabel('Projects'),
    OwnershipType: 'UserOwned', // UserOwned, TeamOwned, OrganizationOwned, None
    Attributes: [
      {
        '@odata.type': 'Microsoft.Dynamics.CRM.StringAttributeMetadata',
        SchemaName: 'new_Name',
        DisplayName: dataverseAPI.buildLabel('Project Name'),
        RequiredLevel: { Value: 'ApplicationRequired' },
        MaxLength: 100,
      },
    ],
  },
  { solutionUniqueName: 'MyCustomSolution' },
)

await dataverseAPI.publishCustomizations('new_project')
```

**Attributes** (v1.0.20): `createAttribute(entityLogicalName, attributeDefinition, options?, connectionTarget?)`, `updateAttribute(...)`, `deleteAttribute(entityLogicalName, attributeIdentifier, connectionTarget?)` — unlike `deleteEntityDefinition`, `deleteAttribute` still needs a follow-up `publishCustomizations()` to complete the deletion.

```typescript
const choiceAttribute = await dataverseAPI.createAttribute('new_project', {
  '@odata.type': dataverseAPI.getAttributeODataType(DataverseAPI.AttributeMetadataType.Picklist),
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

const lookupAttribute = await dataverseAPI.createAttribute('new_project', {
  '@odata.type': dataverseAPI.getAttributeODataType(DataverseAPI.AttributeMetadataType.Lookup),
  SchemaName: 'new_AccountId',
  DisplayName: dataverseAPI.buildLabel('Account'),
  RequiredLevel: { Value: 'None' },
  Targets: ['account'],
})

await dataverseAPI.publishCustomizations('new_project')
```

For a lookup referencing more than one entity type (e.g. a Customer field targeting both Account and Contact), use `createPolymorphicLookupAttribute(entityLogicalName, attributeDefinition, options?, connectionTarget?)` (v1.0.20, returns `{ AttributeId }`) instead of `createAttribute` — or, for customer-specific lookups, the `CreateCustomerRelationships` action via `dataverseAPI.execute()` (Step 7), which creates the lookup and relationships in one operation.

**Relationships** (v1.0.18): `createRelationship(relationshipDefinition, options?, connectionTarget?)`, `updateRelationship(relationshipIdentifier, relationshipDefinition, options?, connectionTarget?)`, `deleteRelationship(relationshipIdentifier, connectionTarget?)`.

```typescript
await dataverseAPI.createRelationship({
  '@odata.type': 'Microsoft.Dynamics.CRM.OneToManyRelationshipMetadata',
  SchemaName: 'new_account_project',
  ReferencedEntity: 'account',
  ReferencedAttribute: 'accountid',
  ReferencingEntity: 'new_project',
  Lookup: {
    '@odata.type': dataverseAPI.getAttributeODataType(DataverseAPI.AttributeMetadataType.Lookup),
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

**Global option sets** (v1.0.20): `createGlobalOptionSet(optionSetDefinition, options?, connectionTarget?)`, `updateGlobalOptionSet(...)`, `deleteGlobalOptionSet(optionSetIdentifier, connectionTarget?)`.

**Option values** (v1.0.20): `insertOptionValue(params, connectionTarget?)`, `updateOptionValue(params, connectionTarget?)`, `deleteOptionValue(params, connectionTarget?)`, `orderOption(params, connectionTarget?)`. `params` is either `{ EntityLogicalName, AttributeLogicalName, ... }` (local option set) or `{ OptionSetName, ... }` (global), plus `Value`/`Label`/`Description` as applicable; `orderOption` instead takes `Values: number[]`, the option values in the desired order.

```typescript
await dataverseAPI.insertOptionValue({
  OptionSetName: 'new_projectstatus',
  Value: 6,
  Label: dataverseAPI.buildLabel('Archived'),
})
await dataverseAPI.publishCustomizations()
```

For status columns (`statuscode`) specifically, use the `InsertStatusValue` action via `dataverseAPI.execute()` (it requires a `StateCode` parameter) instead of `insertOptionValue`.

## Step 7: Actions & functions

`dataverseAPI.execute(request, connectionTarget?)` (v1.0.17) runs a custom action or function through one interface. Set `entityName`/`entityId` for bound operations; omit both for unbound/global ones.

```typescript
// Bound action
const boundResult = await dataverseAPI.execute({
  entityName: 'systemuser',
  entityId: 'user-guid',
  operationName: 'SetBusinessSystemUser',
  operationType: 'action',
  parameters: { BusinessUnit: 'businessunits(bu-guid)', ReassignPrincipal: 'systemusers(user-guid)' },
})

// Unbound function
const unboundResult = await dataverseAPI.execute({
  operationName: 'WhoAmI',
  operationType: 'function',
})
```

## Step 8: Solution deployment

`deploySolution(solutionContent, options?, connectionTarget?)` (v1.0.17) imports a base64 solution zip and returns `{ ImportJobId }`; `options` may include `importJobId`, `publishWorkflows`, `overwriteUnmanagedCustomizations`, `skipProductUpdateDependencies`, `convertToManaged`. Always poll `getImportJobStatus(importJobId, connectionTarget?)` (v1.0.17) afterward rather than assuming the import succeeded — an accepted import job can still fail asynchronously.

```typescript
const solutionFile = await toolboxAPI.fileSystem.readBinary('/path/to/solution.zip')
const result = await dataverseAPI.deploySolution(solutionFile, { publishWorkflows: true })
const status = await dataverseAPI.getImportJobStatus(result.ImportJobId)
```

## Step 9: Reconcile `features.minAPI`

Set `package.json`'s `features.minAPI` to the highest **Requires vX.Y.Z** badge among the methods actually called — most CRUD/query/action methods only need `1.0.17`, relationship writes need `1.0.18`, and schema writes (entities/attributes/option sets) plus `getCSDLDocument`/`buildLabel`/`getAttributeODataType` need `1.0.20`.

## Checklist

- [ ] `retrieve()` and `getEntityRelatedMetadata()` calls request only the columns/properties actually needed.
- [ ] `createMultiple()` / `updateMultiple()` records include `@odata.type` (and `id` for updates).
- [ ] Every metadata-modifying call (creates, updates, and deletes other than `deleteEntityDefinition`) is followed by `dataverseAPI.publishCustomizations()` — `deleteEntityDefinition` is the one documented exception, since it applies immediately.
- [ ] Multi-connection tools pass `'secondary'` explicitly where the secondary environment is intended.
- [ ] Solution imports poll `getImportJobStatus()` until the job completes rather than assuming success.
- [ ] `package.json`'s `features.minAPI` covers the highest **Requires vX.Y.Z** badge among the methods actually called.

## Next steps

- `add-toolbox-api` — get the active/secondary connection this API's `connectionTarget` argument depends on
- `add-powerplatform-api` — for Power Platform surface area Dataverse's Web API doesn't cover (environment management, governance, licensing, etc.)
- `add-error-handling` — retrofit try/catch and user-facing notifications around the calls this skill adds
- `validate-pptb-tool` — run `pptb-validate` before publishing
