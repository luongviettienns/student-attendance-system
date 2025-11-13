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
            console.warn('No token available for SignalR connection');
            return Promise.reject('No token available');
        }
        
        // Get API base URL - SignalR hub is at root, not /api-edu
        // Extract base URL from API_CONFIG.BASE_URL (remove /api-edu)
        var apiBaseUrl = 'http://localhost:5227'; // Default
        try {
            // Try to get from API_CONFIG if available
            var injector = angular.injector(['ng', 'adminApp']);
            var API_CONFIG = injector.get('API_CONFIG');
            if (API_CONFIG && API_CONFIG.BASE_URL) {
                // Remove /api-edu suffix if present
                apiBaseUrl = API_CONFIG.BASE_URL.replace('/api-edu', '');
            }
        } catch (e) {
            // Fallback to default
            console.log('Using default API URL for SignalR');
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
            console.warn('SignalR connection closed', error);
            
            if (reconnectAttempts < maxReconnectAttempts) {
                console.log('Attempting to reconnect...');
            } else {
                console.error('Max reconnection attempts reached');
            }
            
            $rootScope.$broadcast('signalr:disconnected', error);
        });
        
        connection.onreconnecting(function(error) {
            isConnected = false;
            console.log('SignalR reconnecting...', error);
            $rootScope.$broadcast('signalr:reconnecting', error);
        });
        
        connection.onreconnected(function(connectionId) {
            isConnected = true;
            reconnectAttempts = 0;
            console.log('SignalR reconnected', connectionId);
            $rootScope.$broadcast('signalr:reconnected', connectionId);
        });
        
        // Start connection
        return connection.start()
            .then(function() {
                isConnected = true;
                reconnectAttempts = 0;
                console.log('SignalR connected');
                $rootScope.$broadcast('signalr:connected');
                return connection;
            })
            .catch(function(error) {
                console.error('Error starting SignalR connection:', error);
                isConnected = false;
                $rootScope.$broadcast('signalr:error', error);
                throw error;
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
                    console.log('SignalR disconnected');
                    $rootScope.$broadcast('signalr:disconnected');
                })
                .catch(function(error) {
                    console.error('Error stopping SignalR connection:', error);
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
            console.warn('SignalR connection not initialized');
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
            console.warn('SignalR connection not initialized');
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

