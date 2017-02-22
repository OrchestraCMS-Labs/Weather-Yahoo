@isTest
private with sharing class WeatherYahoo_Test {
    private static Map<String, String> testAttributesBase = new Map<String, String> {
        'defaultLocation' => 'Kingston, ON, Canada'
    };
    
    private static testmethod void testGetDefaultLocation_noAttributes() {
        WeatherYahoo controller = new WeatherYahoo();
        
        System.assertEquals('', controller.defaultLocation, 'Default location should return an empty string if attribute is null.');
    }
    
    private static testmethod void testGetDefaultLocation_withAttribute() {
        WeatherYahoo controller = new WeatherYahoo();
        
        controller.testAttributes = testAttributesBase;
        
        System.assertEquals(testAttributesBase.get('defaultLocation'), controller.defaultLocation,
            'Default location should return the stored attribute value.');
    }
    
    private static testmethod void testGetHtml() {
        WeatherYahoo controller = new WeatherYahoo();
        
        controller.testAttributes = testAttributesBase;
        
        String html = controller.getHtml();
        
        System.assert(html.contains(testAttributesBase.get('defaultLocation')), 'HTML should contain the default location');
    }
    
    private static testmethod void testGetHtml_withInjection() {
        WeatherYahoo controller = new WeatherYahoo();
        String injectionCheck = '<script>';
        
        controller.testAttributes = new Map<String, String> { 'defaultLocation' => injectionCheck };
        
        String html = controller.getHtml();
        
        System.assert(html.contains(injectionCheck.escapeHtml4()), 'HTML should escape the default location.');
    }
}
