# Custom Salesforce Development Rules

## CLI Rules

- Never use the `sfdx` command line, use the `sf` command line instead.
- Never use commands from the `force` namespace, use the modern `sf` alternatives instead.

## Metadata Rules

- When creating metadata that requires an `apiVersion` property (Apex, LWC or other), use the version specified in the project's `sfdx-project.json` file.
- When creating an Apex class don't forget to include the metadata `.cls-meta.xml` file.
- When creating a LWC component don't forget to include the metadata `.js-meta.xml` file.
- When deleting metadata, use the `sf project deploy start --post-destructive-changes=destructive-package.xml` command and follow these instructions to write the `destructive-package.xml` file: https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_deploy_deleting_files.htm

## LWC Rules

- When creating HTML for a LWC, never use the legacy `if:true` or `if:false` directives, instead use the modern equivalents: `lwc:if`, `lwc:elseif`, `lwc:else`.
- If creating an LWC that has the `exposed` metadata property set to `true`, fill the `masterLabel` property.
- Do not supply `supportedFormFactors` property in LWC metadata unless specifically requested by the user.

## Apex Rules

- When writing Apex tests, use the `Assert` class static methods instead of the legacy `System.assert`, `System.assertEquals` and `System.assertNotEquals` methods.
- When asked to run Apex tests, first deploy the project's metadata before running the tests.
