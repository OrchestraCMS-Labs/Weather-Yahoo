# Weather Widget Yahoo

<!-- MarkdownTOC depth=3 -->

1. [Summary](#summary)
    1. [Compatibility](#compatibility)
    1. [Prerequisites](#prerequisites)
    1. [Deployment](#deployment)
    1. [Configuration](#configuration)
1. [Versioning](#versioning)
    1. [Major Versions](#major-versions)
    1. [Minor Versions](#minor-versions)
    1. [Patch Versions](#patch-versions)

<!-- /MarkdownTOC -->

<a name="summary"></a>
## Summary

The Weather Yahoo content type provides a *Weather - Yahoo* template to load the current weather conditions for a user and display it in a format suitable for a dashboard.

<a name="compatibility"></a>
### Compatibility

This content type requires a minimum of OrchestraCMS package 7.184 (Winter 2016, v7.3 Build #7.184).

<a name="prerequisites"></a>
### Prerequisites

1. A compatible version of OrchestraCMS is installed in the target Salesforce organization.
2. A site has been created in OrchestraCMS.

<a name="deployment"></a>
### Deployment

1. Deploy the following Apex classes to the target Salesforce organization
    1. WeatherYahoo.cls
    2. WeatherYahoo_Test.cls
    4. WeatherYahooService.cls
    5. WeatherYahooService_Test.cls
2. Deploy the following static resources
    1. WeatherYahoo.resource
3. Deploy the following Visualforce pages to the target Salesforce organization
    1. WeatherYahoo_Edit.page

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

<a name="configuration"></a>
### Configuration

Create OrchestraCMS Content Layout records with the following field values:

```
Name : WeatherYahoo
Label : Weather - Yahoo
Controller : WeatherYahoo
isPageCacheable : true
isContentCacheable : true
Visualforce Edit : c__WeatherYahoo_Edit
```

On the target OrchestraCMS site create the following content type(s) and add content templates as indicated.

```
Name: WeatherYahoo
Label: Weather Yahoo
Templates:
    Weather - Yahoo, autocreate, default
```

<a name="versioning"></a>
## Versioning

Versions of this content type are numbered MAJOR.MINOR.PATCH.

Any modifications to this code outside of this repository are customizations and will impact upgradeability.

<a name="major-versions"></a>
### Major Versions

Major versions introduce new functionality and may break existing implementations.

<a name="minor-versions"></a>
### Minor Versions

Minor versions introduce new functionality, but will not break existing implementations.

<a name="patch-versions"></a>
### Patch Versions

Patches correct defects in the implementation and do not introduce new functionality.
