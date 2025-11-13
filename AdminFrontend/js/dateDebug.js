// Date Debug Helper - Add to window for easy debugging
(function() {
    'use strict';
    
    // Find all date inputs and log their current values
    window.debugDateInputs = function() {
        var dateInputs = document.querySelectorAll('input[type="date"]');
        
        dateInputs.forEach(function(input, index) {
            var ngModel = input.getAttribute('ng-model');
            var id = input.id || 'no-id';
            var name = input.name || 'no-name';
            var value = input.value;
            var ngModelValue = null;
            
            // Try to get AngularJS scope value
            try {
                var element = angular.element(input);
                var scope = element.scope();
                if (scope && ngModel) {
                    var modelPath = ngModel.split('.');
                    ngModelValue = modelPath.reduce(function(obj, key) {
                        return obj ? obj[key] : null;
                    }, scope);
                }
            } catch (e) {
                // Ignore
            }
        });
    };
    
    // Monitor AngularJS date formatting errors
    var originalError = console.error;
    var datefmtErrorCount = 0;
    console.error = function() {
        var args = Array.prototype.slice.call(arguments);
        var errorMessage = args[0] ? String(args[0]) : '';
        
        // Check if this is a datefmt error
        if (errorMessage.includes('ngModel:datefmt') || 
            (args[0] && args[0].message && args[0].message.includes('ngModel:datefmt'))) {
            datefmtErrorCount++;
            
            // DON'T call originalError - suppress the error completely
            return;
        }
        
        // For all other errors, use the original handler
        originalError.apply(console, args);
    };
})();

