---
title: add-dataverse-api
description: Adds window.dataverseAPI CRUD, query, and metadata calls to a PPTB tool, keeping metadata changes paired with publishCustomizations().
last_verified: 2026-07-22
---

# add-dataverse-api

This skill automates adding `window.dataverseAPI` calls to a PPTB tool — the HTTP client for CRUD operations, FetchXML/OData queries, entity/attribute/relationship/option-set metadata, custom action and function execution, and solution deployment against Dataverse. A developer reaches for it whenever the tool needs to read, write, or reshape Dataverse data or schema.

**Every metadata-modifying call this skill generates — creating or updating an entity, attribute, relationship, or option set — is followed by a call to `dataverseAPI.publishCustomizations()`, since those changes don't take effect in the environment until published.**

## When to use it

- "Create/retrieve/update/delete a record from Dataverse in my tool"
- "Run a FetchXML query" / "run an OData query with filters"
- "Create a custom table with these columns"
- "Add a choice field / lookup field / relationship to this table"
- "Call this custom action" / "call this custom function"
- "Deploy this solution zip from my tool"
- "Get metadata for this entity" / "list all entities"

## Inputs

- Which operation category is needed: CRUD, relationship association, query (FetchXML/OData), metadata read, entity/attribute/relationship/option-set write, action/function execution, or solution deployment
- Entity logical name(s) and the columns/attributes involved
- For writes: the record shape, or the full attribute/entity/relationship/option-set definition (schema name, display name, type, required level, etc.)
- Whether the call should target the primary or secondary connection (`connectionTarget`)
- For custom actions/functions: operation name, `operationType` (`'action' | 'function'`), bound entity name/id if bound, and parameters

## What it does

1. Adds CRUD calls — `dataverseAPI.create(entityLogicalName, record, connectionTarget?)`, `.retrieve(entityLogicalName, id, columns?, connectionTarget?)`, `.update(...)`, `.delete(...)`, `.createMultiple(entityLogicalName, records, connectionTarget?)`, `.updateMultiple(...)` — requesting only the columns actually needed on `retrieve()`, and including `@odata.type` on every record passed to `createMultiple`/`updateMultiple` (plus `id` for updates).
2. Adds relationship association calls — `dataverseAPI.associate(...)` / `.disassociate(...)` — for many-to-many relationships.
3. Adds query calls — `dataverseAPI.fetchXmlQuery(fetchXml, connectionTarget?)` for FetchXML, `dataverseAPI.queryData(odataQuery, connectionTarget?)` for OData (`$select`, `$filter`, `$orderby`, `$top`, `$skip`, `$expand`).
4. Adds metadata reads — `dataverseAPI.getEntityMetadata(...)`, `.getEntityRelatedMetadata(entityLogicalName, relatedPath, ...)`, `.getAllEntitiesMetadata(...)`, `.getEntitySetName(logicalName)`, and `.getCSDLDocument(connectionTarget?)` for the full CSDL/EDMX document when the tool needs to enumerate custom actions/functions or inspect entity shapes.
5. Adds entity/attribute/relationship/option-set writes — `createEntityDefinition`, `updateEntityDefinition`, `deleteEntityDefinition`, `createAttribute`, `updateAttribute`, `deleteAttribute`, `createPolymorphicLookupAttribute`, `createRelationship`, `updateRelationship`, `deleteRelationship`, `createGlobalOptionSet`, `updateGlobalOptionSet`, `deleteGlobalOptionSet`, `insertOptionValue`, `updateOptionValue`, `deleteOptionValue`, `orderOption` — using `dataverseAPI.buildLabel(text, languageCode?)` for every `Label`/`DisplayName` field and `dataverseAPI.getAttributeODataType(attributeType)` for every attribute's `@odata.type`.
6. Appends `await dataverseAPI.publishCustomizations(tableLogicalName?, connectionTarget?)` immediately after every metadata-modifying call in step 5 (entity deletion is the one exception — it takes effect immediately and needs no publish call).
7. Adds `dataverseAPI.execute(request, connectionTarget?)` for custom actions/functions, setting `entityName`/`entityId` for bound operations and omitting them for unbound ones.
8. For solution deployment, adds `dataverseAPI.deploySolution(solutionContent, options?, connectionTarget?)` followed by a polling loop on `dataverseAPI.getImportJobStatus(importJobId, connectionTarget?)` rather than assuming the import succeeded.

## Example

Before: no schema for a "Project" table.

After:

```typescript
const newEntity = await dataverseAPI.createEntityDefinition({
  '@odata.type': 'Microsoft.Dynamics.CRM.EntityMetadata',
  LogicalName: 'new_project',
  DisplayName: dataverseAPI.buildLabel('Project'),
  DisplayCollectionName: dataverseAPI.buildLabel('Projects'),
  OwnershipType: 'UserOwned',
  Attributes: [
    {
      '@odata.type': 'Microsoft.Dynamics.CRM.StringAttributeMetadata',
      SchemaName: 'new_Name',
      DisplayName: dataverseAPI.buildLabel('Project Name'),
      RequiredLevel: { Value: 'ApplicationRequired' },
      MaxLength: 100,
    },
  ],
})

await dataverseAPI.publishCustomizations('new_project')
```

## Checklist it enforces

- [ ] `retrieve()` and `getEntityRelatedMetadata()` calls request only the columns/properties actually needed.
- [ ] `createMultiple()` / `updateMultiple()` records include `@odata.type` (and `id` for updates).
- [ ] Every metadata-modifying call (`createEntityDefinition`, `createAttribute`, `createRelationship`, `createGlobalOptionSet`, option value operations, and their update/delete counterparts) is followed by `dataverseAPI.publishCustomizations()`.
- [ ] Multi-connection tools pass `'secondary'` explicitly where the secondary environment is intended.
- [ ] Solution imports poll `getImportJobStatus()` until the job completes rather than assuming success.

## Related

- [Dataverse API](/pptb-tools/tool-development/dataverse-api/) — the API reference this skill is built on
- Related skills: `../add-toolbox-api/`, `../add-powerplatform-api/`
