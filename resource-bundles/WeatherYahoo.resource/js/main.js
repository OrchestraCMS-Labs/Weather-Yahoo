window.STG = window.STG || {};
window.STG.CTLib = window.STG.CTLib || {};

window.STG.CTLib.WeatherYahoo = (function(global, namespace, undefined) {
    'use strict';

    var serviceName = 'WeatherYahooService';

    var currentConditionsSelector = '[data-currentweatherconditions]';

    var yahooCodeToWeatherIconClass = {
        'default': 'wi-cloud',
        '0': 'wi-tornado',
        '1': 'wi-storm-showers',
        '2': 'wi-tornado',
        '3': 'wi-thunderstorm',
        '4': 'wi-thunderstorm',
        '5': 'wi-snow',
        '6': 'wi-rain-mix',
        '7': 'wi-rain-mix',
        '8': 'wi-sprinkle',
        '9': 'wi-sprinkle',
        '10': 'wi-hail',
        '11': 'wi-showers',
        '12': 'wi-showers',
        '13': 'wi-snow',
        '14': 'wi-storm-showers',
        '15': 'wi-snow',
        '16': 'wi-snow',
        '17': 'wi-hail',
        '18': 'wi-hail',
        '19': 'wi-cloudy-gusts',
        '20': 'wi-fog',
        '21': 'wi-fog',
        '22': 'wi-fog',
        '23': 'wi-cloudy-gusts',
        '24': 'wi-cloudy-windy',
        '25': 'wi-thermometer',
        '26': 'wi-cloudy',
        '27': 'wi-night-cloudy',
        '28': 'wi-day-cloudy',
        '29': 'wi-night-cloudy',
        '30': 'wi-day-cloudy',
        '31': 'wi-night-clear',
        '32': 'wi-day-sunny',
        '33': 'wi-night-clear',
        '34': 'wi-day-sunny-overcast',
        '35': 'wi-hail',
        '36': 'wi-day-sunny',
        '37': 'wi-thunderstorm',
        '38': 'wi-thunderstorm',
        '39': 'wi-thunderstorm',
        '40': 'wi-storm-showers',
        '41': 'wi-snow',
        '42': 'wi-snow',
        '43': 'wi-snow',
        '44': 'wi-cloudy',
        '45': 'wi-lightning',
        '46': 'wi-snow',
        '47': 'wi-thunderstorm',
        '3200': 'wi-cloud'
    };

    $(function() {
        $(currentConditionsSelector).each(function() {
            namespace.initCurrentConditionsWidget($(this));
        });
    });

    namespace.initCurrentConditionsWidget = function($container) {
        var defaultLocation = $container.attr('data-defaultlocation');

        namespace.getUserCurrentConditions(defaultLocation, function(alwaysTrue, result) {
            if(!result.success) {
                console.error(result.message);
            } else {
                namespace.renderCurrentConditions($container, result.condition)
            }
        });
    };

    namespace.renderCurrentConditions = function($container, condition) {
        var conditionClass = yahooCodeToWeatherIconClass[condition.code];

        var $mediaObject = $('<div class="media" />').append(
            $('<div class="media-left" />').append(
                $('<a />').prop({
                    'href': condition.link,
                    target: '_blank'
                }).append(
                    $('<i class="wi ' + conditionClass + '" style="line-height:1.5; font-size: 1.5em;" />')
                )
            ),
            $('<div class="media-body" />').append(
                $('<h4 class="media-heading" />').append(
                    $('<span />').text(condition.temperature + condition.units),
                    '<a href="https://www.yahoo.com/?ilc=401" target="_blank"><img src="https://poweredby.yahoo.com/purple.png" width="134" height="29"/></a>'
                )
            )
        );

        $container.empty().append($mediaObject);
    };

    namespace.getUserCurrentConditions = function(defaultLocation, callback) {
        $.orchestracmsRestProxy.doAjaxServiceRequest(serviceName, {
            action: 'getUserCurrentConditions',
            defaultLocation: defaultLocation
        }, callback, null, true); // Read-only mode
    };

    return namespace;
}(window, STG.CTLib.WeatherYahoo || {}));
