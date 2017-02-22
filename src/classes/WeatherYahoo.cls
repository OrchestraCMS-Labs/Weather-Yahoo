/** Provides getHTML implementations for the content template "WeatherYahoo" */
global virtual with sharing class WeatherYahoo extends cms.ContentTemplateController {
    /** Returns cacheable HTML for a Current Weather Conditions widget */
    global virtual override String getHTML() {
        String html = '';

        html += '<div data-currentweatherconditions'
            + ' data-defaultlocation="' + defaultLocation.escapeHtml4() + '">'
            + '</div>';

        return html;
    }

    public String defaultLocation {
        get {
            String location = getAttribute('defaultLocation');
            if(location == null) {
                return '';
            } else {
                return location;
            }
        }
    }

    /** Provides an easy way to define attributes during testing */
    @TestVisible
    private Map<String, String> testAttributes = new Map<String, String>();

    /** Delegates to ContentTemplateController#getProperty in normal execution. Accesses the {@link #testAttributes}
     * map in a test context.
     */
    private String getAttribute(String attributeName) {
        if(Test.isRunningTest()) {
            return testAttributes.get(attributeName);
        } else {
            return getProperty(attributeName);
        }
    }

    /** Extension constructor for the Article edit page */
    global WeatherYahoo(cms.CreateContentController cc) {
        super(cc);
    }

    /** Extension constructor for Article generate pages (unused) */
    private WeatherYahoo(cms.GenerateContent gc) {
        super(gc);
    }

    /** Constructor for getHTML rendering */
    global WeatherYahoo() {
        super();
    }
}
