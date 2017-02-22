/**
 * Processes actions related to the content template "CurrentWeatherConditionsYahoo"
 */
global with sharing class WeatherYahooService implements cms.ServiceInterface {
    /** Stores the template for a YQL (Yahoo Query Language) request URL */
    private static final String URL_TEMPLATE;
    private static final String LOCATION_TOKEN = '_locationString_';

    private static final String[] fahrenheitCountries
        = new String[] { 'The Bahamas', 'United States', 'Belize', 'Cayman Islands', 'Palau' };

    static {
        String yqlQuery = 'SELECT link, location, item.condition '
            + 'FROM weather.forecast '
            + 'WHERE woeid IN (SELECT woeid FROM geo.places(1) WHERE text="' + LOCATION_TOKEN + '")';

        URL_TEMPLATE = 'https://query.yahooapis.com/v1/public/yql'
            + '?q=' + EncodingUtil.urlEncode(yqlQuery, 'UTF-8')
            + '&format=json'
            + '&env=' + EncodingUtil.urlEncode('store://datatables.org/alltableswithkeys', 'UTF-8');
    }

    /**
     * Core handler method for retrieving current weather conditions from Yahoo's service, either for a specific
     * location or for the current user's location as stored in Salesforce.
     *
     * @param params a map of parameters including at minimum a value for 'action'
     * @return a JSON-serialized response string
     */
    public String executeRequest(Map<String, String> params) {
        String action = params.get('action');

        try {
            if(action == 'getUserCurrentConditions') {
                return getUserCurrentConditionsJson(params);
            } else if(action == 'getCurrentConditions') {
                return getCurrentConditionsJson(params);
            }
        } catch(Exception e) {
            // Unexpected error
            String message = e.getMessage();

            return '{"success":false,"message":' + JSON.serialize(message) + '}';
        }

        // No actions matched and no error occurred
        return '{"success":false,"message":"Invalid Action"}';
    }

    /** Represents the current weather conditions for a location */
    public class CurrentCondition {
        public Decimal temperature;

        /** One of 'F' (fahrenheit) or '°C' (celsius) */
        public String units;

        public String code;
        public String link;
    }

    public class WeatherYahooServiceException extends Exception {}

    private String getUserCurrentConditionsJson(Map<String, String> params) {
        String defaultLocation = params.get('defaultLocation');

        CurrentCondition condition = getUserCurrentConditions(defaultLocation);

        return '{"success":true,"condition":' + JSON.serialize(condition) + '}';
    }

    /**
     * Fetches the current weather conditions for the current user.
     *
     * If the current user doesn't have their City and Country set it will instead fetch the current weather conditions
     * for the default location specified.
     *
     * @param defaultLocation a fallback location to fetch conditions for. Should be formatted as 'City, Country' or 'City, Region, Country'
     * @return a {@link #CurrentCondition} for the fetched weather conditions
     */
    public CurrentCondition getUserCurrentConditions(String defaultLocation) {
        String locationString = defaultLocation;
        String response;
        CurrentCondition condition;

        if(UserInfo.getUserType() != 'Guest') {
            User u = [SELECT City, State, Country FROM User WHERE Id = :UserInfo.getUserId()];

            if(String.isNotBlank(u.City) && String.isNotBlank(u.State)) {
                locationString = u.City + ', ' + u.State + ', ' + u.Country;
            } else if(String.isNotBlank(u.City)) {
                locationString = u.City + ', ' + u.Country;
            }
        }

        return getCurrentConditions(locationString);
    }

    private String getCurrentConditionsJson(Map<String, String> params) {
        String location = params.get('location');

        CurrentCondition condition = getCurrentConditions('location');

        return '{"success":true,"condition":' + JSON.serialize(condition) + '}';
    }

    /**
     * Fetches the current weather conditions for a location.
     *
     * @param location the location to fetch conditions for. Should be formatted as 'City, Country' or 'City, Region, Country'
     */
    public CurrentCondition getCurrentConditions(String location) {
        String response = calloutCurrentConditions(location);
        CurrentCondition condition = parseCurrentConditionsResponse(response);

        return condition;
    }

    /** Performs the callout to fetch the current weather conditions for a given location */
    private String calloutCurrentConditions(String location) {
        String requestUrl = URL_TEMPLATE.replaceAll(LOCATION_TOKEN, EncodingUtil.urlEncode(location, 'UTF-8'));

        System.debug('Requesting ' + requestUrl);

        HTTPRequest conditionsRequest = new HTTPRequest();
        conditionsRequest.setEndpoint(requestUrl);
        conditionsRequest.setCompressed(true);
        conditionsRequest.setMethod('GET');

        HTTP http = new HTTP();
        HTTPResponse conditionsResponse;

        try {
            conditionsResponse = http.send(conditionsRequest);
        } catch(Exception e) {
            System.debug(e);
            throw new WeatherYahooServiceException('Current conditions fetch failed: \n\n' + e.getMessage());
        }

        if(conditionsResponse.getStatusCode() != 200) {
            throw new WeatherYahooServiceException(
                'Current conditions fetch failed: \n\n' + conditionsResponse.getStatusCode() + ': '
                    + conditionsResponse.getStatus()
            );
        }

        System.debug('Response: ' + conditionsResponse.getBody());

        return conditionsResponse.getBody();
    }

    /** Parses an API response from Yahoo into a CurrentCondition object */
    private CurrentCondition parseCurrentConditionsResponse(String response) {
        /* Sample response:
         * {
         *      "query": {
         *          "count": 1,
         *          "created": "yyyy-mm-ddThh:mm:ssZ",
         *          "lang": "en-US",
         *          "results": {
         *              "channel": {
         *                  "link": "http://us.rd.yahoo.com/...",
         *                  "location": {
         *                      "city": "city_name",
         *                      "country": "country_name",
         *                      "region": "region_name"
         *                  },
         *                  "item": {
         *                      "condition": {
         *                          "code": "23",
         *                          "date": "Thu, 01 Jan 2000 00:00 PM EDT",
         *                          "temp": "{temp_in_F}",
         *                          "text": "Breezy"
         *                      }
         *                  }
         *              }
         *          }
         *      }
         *  }
         */

        CurrentCondition condition = new CurrentCondition();

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        Map<String, Object> queryMap = (Map<String, Object>)responseMap.get('query');
        Map<String, Object> resultsMap = (Map<String, Object>)queryMap.get('results');

        if(resultsMap == null) {
            return null;
        }

        Map<String, Object> channelMap = (Map<String, Object>)resultsMap.get('channel');

        String link = (String)channelMap.get('link');
        Map<String, Object> locationMap = (Map<String, Object>)channelMap.get('location');

        Map<String, Object> itemMap = (Map<String, Object>)channelMap.get('item');
        Map<String, Object> conditionMap = (Map<String, Object>)itemMap.get('condition');

        String country = (String)locationMap.get('country');
        Decimal temperatureF = Decimal.valueOf((String)conditionMap.get('temp'));
        String conditionCode = (String)conditionMap.get('code');

        Boolean isFahrenheit = false;
        for(String fahrenheitCountry : fahrenheitCountries) {
            if(fahrenheitCountry == country) {
                isFahrenheit = true;
            }
        }

        if(isFahrenheit) {
            condition.temperature = Math.round(temperatureF);
            condition.units = 'F';
        } else {
            condition.temperature = Math.round(fahrenheitToCelsius(temperatureF));
            condition.units = '°C';
        }

        condition.code = conditionCode;
        condition.link = link;

        return condition;
    }

    private static Decimal fahrenheitToCelsius(Decimal fahrenheit) {
        return (fahrenheit - 32) * (5.0 / 9.0);
    }

    public static Type getType() {
        return WeatherYahooService.class;
    }
}
