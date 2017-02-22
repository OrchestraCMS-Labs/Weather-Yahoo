@isTest
private with sharing class WeatherYahooService_Test {
    private static final String DEFAULT_LOCATION = 'Kingston, ON, Canada';
    private static final String FAHRENHEIT_LOCATION = 'New York, NY';
    private static final Decimal TEMP_F = 45;
    private static final Decimal TEMP_C = Math.round((TEMP_F - 32) * (5.0 / 9.0));
    private static WeatherYahooService service = new WeatherYahooService();
    
    private static testmethod void testExecuteRequest_getUserCurrentConditions() {
        String city = 'Kingston';
        String state = 'ON';
        String country = 'Canada';
        
        Test.setMock(HTTPCalloutMock.class, new WeatherCalloutSuccess(country));
        
        String response;
        
        System.runAs(createTestUser(city, state, country)) {
            Test.startTest();
            
            Map<String, String> params = new Map<String, String> {
                'action' => 'getUserCurrentConditions',
                'defaultLocation' => DEFAULT_LOCATION
            };
    
            response = service.executeRequest(params);
            
            Test.stopTest();
        }

        System.assert(response.contains('"success":true'), 'JSON response should be successful');
    }
    
    private static testmethod void testExecuteRequest_getCurrentConditions() {
        Test.setMock(HTTPCalloutMock.class, new WeatherCalloutSuccess('Canada'));
        
        Map<String, String> params = new Map<String, String> {
            'action' => 'getCurrentConditions',
            'location' => DEFAULT_LOCATION
        };
    
        String response = service.executeRequest(params);
            
        System.assert(response.contains('"success":true'), 'JSON response should be successful');
    }
    
    private static testmethod void testExecuteRequest_exception() {
        Test.setMock(HTTPCalloutMock.class, new WeatherCalloutExceptionMock());
        
        Map<String, String> params = new Map<String, String> {
            'action' => 'getCurrentConditions',
            'location' => DEFAULT_LOCATION
        };
    
        String response = service.executeRequest(params);
            
        System.assert(response.contains('"success":false'), 'JSON response should not be successful');
    }
    
    private static testmethod void testExecuteRequest_invalidAction() {
        // No HTTP mock - no callout should happen
        Map<String, String> params = new Map<String, String> {
            'action' => 'invalid_action'
        };

        String response = service.executeRequest(params);

        System.assert(response.contains('"success":false'), 'JSON response should not be successful');
    }
    
    private static testmethod void testGetUserCurrentConditions_cityStateCountry() {
        String city = 'Kingston';
        String state = 'ON';
        String country = 'Canada';
        
        Test.setMock(HTTPCalloutMock.class, new WeatherCalloutSuccess(country));
        
        System.runAs(createTestUser(city, state, country)) {
            Test.startTest();

            WeatherYahooService.CurrentCondition currentCondition = service.getUserCurrentConditions(DEFAULT_LOCATION);
        
            System.assertNotEquals(null, currentCondition, 'Should return a valid weather condition');
            
            Test.stopTest();
        }
    }
    
    private static testmethod void testGetUserCurrentConditions_cityCountry() {
        String city = 'Kingston';
        String state = null;
        String country = 'Canada';
        
        Test.setMock(HTTPCalloutMock.class, new WeatherCalloutSuccess(country));
        
        System.runAs(createTestUser(city, state, country)) {
            Test.startTest();

            WeatherYahooService.CurrentCondition currentCondition = service.getUserCurrentConditions(DEFAULT_LOCATION);
        
            System.assertNotEquals(null, currentCondition, 'Should return a valid weather condition');
            
            Test.stopTest();
        }
    }
    
    private static testmethod void testGetCurrentConditions() {
        Test.setMock(HTTPCalloutMock.class, new WeatherCalloutSuccess('Canada'));
        
        WeatherYahooService.CurrentCondition currentCondition = service.getCurrentConditions(DEFAULT_LOCATION);
        
        System.assertNotEquals(null, currentCondition, 'Should return a valid weather condition');
        System.assertEquals(TEMP_C, currentCondition.temperature, 'Should return a celsius temperature');
    }
    
    private static testmethod void testGetCurrentConditions_fahrenheit() {
        Test.setMock(HTTPCalloutMock.class, new WeatherCalloutSuccess('United States'));
        
        WeatherYahooService.CurrentCondition currentCondition = service.getCurrentConditions(FAHRENHEIT_LOCATION);
        
        System.assertNotEquals(null, currentCondition, 'Should return a valid weather condition');
        System.assertEquals(TEMP_F, currentCondition.temperature, 'Should return a fahrenheit temperature');
    }
    
    private static testmethod void testGetCurrentConditions_exception() {
        Test.setMock(HTTPCalloutMock.class, new WeatherCalloutExceptionMock());
        
        try {
            WeatherYahooService.CurrentCondition currentCondition = service.getCurrentConditions(DEFAULT_LOCATION);
            System.assert(false, 'Should throw an exception');
        } catch(WeatherYahooService.WeatherYahooServiceException e) {
            // Expected
        }
    }
    
    private static testmethod void testGetCurrentConditions_failure() {
        Test.setMock(HTTPCalloutMock.class, new WeatherCalloutFailureMock());
        
        try {
            WeatherYahooService.CurrentCondition currentCondition = service.getCurrentConditions(DEFAULT_LOCATION);
            System.assert(false, 'Should throw an exception');
        } catch(WeatherYahooService.WeatherYahooServiceException e) {
            // Expected
        }
    }
    
    private static testmethod void testGetType() {
        System.assertEquals(WeatherYahooService.class, WeatherYahooService.getType());
    }
                          
    private static User createTestUser(String city, String state, String country) {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias='test', Email='test@test.com', LastName='Testing', LanguageLocaleKey='en_US',
                          EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', UserName='ocms_weather_test@test.com',
                          LocaleSidKey='en_US', ProfileId = p.Id, City=city, State=state, Country=country);
        return u;
    }
    
    private class WeatherCalloutSuccess implements HttpCalloutMock {
        private String country;
        
        public WeatherCalloutSuccess(String country) {
            this.country = country;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json; charset=UTF-8');
            res.setBody('{"query":{"count":1,"created":"2016-04-01T22:01:38Z","lang":"en-US","results":{"channel":{"link":"http://us.rd.yahoo.com/dailynews/rss/weather/Country__Country/*https://weather.yahoo.com/country/state/city-91981866/","location":{"city":"Kingston","country":"' + this.country + '","region":" ON"},"item":{"condition":{"code":"28","date":"Fri, 01 Apr 2016 04:00 PM EST","temp":"' + TEMP_F + '","text":"Mostly Cloudy"}}}}}}');
            return res;
        }
    }
    
    private class WeatherCalloutExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('HTTP Callout Failed');

            return null;
        }
    }

    private class WeatherCalloutFailureMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(500); // Internal server error

            return res;
        }
    }
}
