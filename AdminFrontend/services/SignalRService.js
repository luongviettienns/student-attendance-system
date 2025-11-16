// @ts-check
/* global angular, signalR */
'use strict';

// SignalR Service for real-time notifications
app.service('SignalRService', ['$rootScope', 'AuthService', function($rootScope, AuthService) {
    var connection = null;
    var isConnected = false;
    var reconnectAttempts = 0;
    var maxReconnectAttempts = 5;
    
    /**
     * Initialize SignalR connection
     */
    this.initialize = function() {
        if (connection) {
            return Promise.resolve();
        }
        
        var token = AuthService.getToken();
        if (!token) {
            return Promise.reject('No token available');
        }
        
        // Get API base URL - SignalR hub needs direct connection (not via Gateway)
        // SignalR uses WebSocket which needs direct connection to Admin API
        // Gateway is only for HTTP REST APIs
        var apiBaseUrl = 'http://localhost:5227'; // Default: Direct to Admin API
        try {
            // Try to get from API_CONFIG if available
            var injector = angular.injector(['ng', 'adminApp']);
            var API_CONFIG = injector.get('API_CONFIG');
            if (API_CONFIG && API_CONFIG.BASE_URL) {
                // If using Gateway, SignalR still needs direct connection to Admin API
                // Gateway URL (https://localhost:7033) -> Admin API (http://localhost:5227)
                if (API_CONFIG.BASE_URL.includes('localhost:7033')) {
                    // Using Gateway - SignalR connects directly to Admin API
                    apiBaseUrl = 'http://localhost:5227';
                } else {
                    // Not using Gateway - use API_CONFIG directly
                    apiBaseUrl = API_CONFIG.BASE_URL.replace('/api-edu', '');
                }
            }
        } catch (e) {
            // Fallback to default
        }
        
        var hubUrl = apiBaseUrl + '/notificationHub';
        
        // Create connection
        connection = new signalR.HubConnectionBuilder()
            .withUrl(hubUrl, {
                accessTokenFactory: function() {
                    return token;
                },
                skipNegotiation: false,
                transport: signalR.HttpTransportType.WebSockets | signalR.HttpTransportType.LongPolling
            })
            .withAutomaticReconnect({
                nextRetryDelayInMilliseconds: function(retryContext) {
                    if (retryContext.previousRetryCount < maxReconnectAttempts) {
                        return Math.min(1000 * Math.pow(2, retryContext.previousRetryCount), 30000);
                    }
                    return null; // Stop reconnecting
                }
            })
            .configureLogging(signalR.LogLevel.Warning)
            .build();
        
        // Connection event handlers
        connection.onclose(function(error) {
            isConnected = false;
            reconnectAttempts++;
            
            if (reconnectAttempts >= maxReconnectAttempts && error) {
                // Only log critical errors
            }
            
            $rootScope.$broadcast('signalr:disconnected', error);
        });
        
        connection.onreconnecting(function(error) {
            isConnected = false;
            $rootScope.$broadcast('signalr:reconnecting', error);
        });
        
        connection.onreconnected(function(connectionId) {
            isConnected = true;
            reconnectAttempts = 0;
            $rootScope.$broadcast('signalr:reconnected', connectionId);
        });
        
        // Start connection
        return connection.start()
            .then(function() {
                isConnected = true;
                reconnectAttempts = 0;
                $rootScope.$broadcast('signalr:connected');
                return connection;
            })
            .catch(function(error) {
                isConnected = false;
                $rootScope.$broadcast('signalr:error', error);
                // Don't throw error - let the app continue with polling fallback
                // Return a rejected promise that can be caught but won't break the app
                return Promise.reject(error);
            });
    };
    
    /**
     * Disconnect SignalR
     */
    this.disconnect = function() {
        if (connection) {
            return connection.stop()
                .then(function() {
                    isConnected = false;
                    connection = null;
                    $rootScope.$broadcast('signalr:disconnected');
                })
                .catch(function(error) {
                    // Ignore disconnect errors
                });
        }
        return Promise.resolve();
    };
    
    /**
     * Register handler for receiving notifications
     * @param {Function} handler - Function to handle notification
     */
    this.onReceiveNotification = function(handler) {
        if (!connection) {
            return;
        }
        
        connection.on('ReceiveNotification', function(notification) {
            $rootScope.$apply(function() {
                handler(notification);
            });
        });
    };
    
    /**
     * Register handler for unread count updates
     * @param {Function} handler - Function to handle count update
     */
    this.onUpdateUnreadCount = function(handler) {
        if (!connection) {
            return;
        }
        
        connection.on('UpdateUnreadCount', function(count) {
            $rootScope.$apply(function() {
                handler(count);
            });
        });
    };
    
    /**
     * Check if connected
     */
    this.isConnected = function() {
        return isConnected && connection && connection.state === signalR.HubConnectionState.Connected;
    };
    
    /**
     * Get connection state
     */
    this.getConnectionState = function() {
        if (!connection) return 'Disconnected';
        return signalR.HubConnectionState[connection.state] || 'Unknown';
    };
}]);

