// ============================================================
// DEBUG HELPER SCRIPT FOR REGISTRATION PERIOD PAGE
// Copy và paste vào Console để debug
// ============================================================

(function() {
    'use strict';
    
    console.log('========================================');
    console.log('🔍 DEBUG REGISTRATION PERIOD PAGE');
    console.log('========================================');
    
    // 1. Kiểm tra jQuery
    console.log('\n1️⃣ jQuery Check:');
    console.log('   jQuery available:', typeof $ !== 'undefined');
    if (typeof $ !== 'undefined') {
        console.log('   jQuery version:', $.fn.jquery);
    } else {
        console.error('   ❌ jQuery NOT FOUND!');
    }
    
    // 2. Kiểm tra AngularJS
    console.log('\n2️⃣ AngularJS Check:');
    console.log('   AngularJS available:', typeof angular !== 'undefined');
    if (typeof angular !== 'undefined') {
        console.log('   AngularJS version:', angular.version.full);
    } else {
        console.error('   ❌ AngularJS NOT FOUND!');
    }
    
    // 3. Kiểm tra ModalUtils
    console.log('\n3️⃣ ModalUtils Check:');
    console.log('   ModalUtils available:', typeof window.ModalUtils !== 'undefined');
    if (window.ModalUtils) {
        console.log('   ModalUtils object:', window.ModalUtils);
        console.log('   ModalUtils.open:', typeof window.ModalUtils.open);
        console.log('   ModalUtils.close:', typeof window.ModalUtils.close);
        console.log('   ModalUtils.closeAll:', typeof window.ModalUtils.closeAll);
    } else {
        console.warn('   ⚠️ ModalUtils NOT FOUND - will use jQuery fallback');
    }
    
    // 4. Kiểm tra Modal Elements
    console.log('\n4️⃣ Modal Elements Check:');
    var $modal = $('#periodModal');
    var $overlay = $('#modal-overlay');
    console.log('   Modal element found:', $modal.length > 0);
    console.log('   Overlay element found:', $overlay.length > 0);
    
    if ($modal.length > 0) {
        console.log('   Modal ID:', $modal.attr('id'));
        console.log('   Modal classes:', $modal.attr('class'));
        console.log('   Modal has "active" class:', $modal.hasClass('active'));
        console.log('   Modal display:', $modal.css('display'));
        console.log('   Modal visibility:', $modal.css('visibility'));
        console.log('   Modal z-index:', $modal.css('z-index'));
        console.log('   Modal position:', $modal.css('position'));
        console.log('   Modal is visible:', $modal.is(':visible'));
    } else {
        console.error('   ❌ Modal element NOT FOUND in DOM!');
    }
    
    if ($overlay.length > 0) {
        console.log('   Overlay ID:', $overlay.attr('id'));
        console.log('   Overlay classes:', $overlay.attr('class'));
        console.log('   Overlay has "active" class:', $overlay.hasClass('active'));
        console.log('   Overlay display:', $overlay.css('display'));
        console.log('   Overlay background:', $overlay.css('background-color'));
    } else {
        console.error('   ❌ Overlay element NOT FOUND in DOM!');
    }
    
    // 5. Kiểm tra Controller
    console.log('\n5️⃣ Controller Check:');
    var controllerElement = document.querySelector('[ng-controller="RegistrationPeriodController"]');
    console.log('   Controller element found:', controllerElement !== null);
    
    if (controllerElement && typeof angular !== 'undefined') {
        try {
            var scope = angular.element(controllerElement).scope();
            console.log('   Controller scope:', scope);
            console.log('   Periods count:', scope.periods ? scope.periods.length : 0);
            console.log('   Current period:', scope.currentPeriod);
            console.log('   Loading:', scope.loading);
            console.log('   Selected period:', scope.selectedPeriod);
        } catch (e) {
            console.error('   ❌ Error getting scope:', e);
        }
    }
    
    // 6. Kiểm tra Button
    console.log('\n6️⃣ Button Check:');
    var createButton = document.querySelector('[ng-click="showCreateModal()"]');
    console.log('   Create button found:', createButton !== null);
    if (createButton) {
        console.log('   Button text:', createButton.textContent.trim());
        console.log('   Button disabled:', createButton.disabled);
        console.log('   Button onclick:', createButton.onclick);
    } else {
        console.error('   ❌ Create button NOT FOUND!');
    }
    
    // 7. Kiểm tra CSS
    console.log('\n7️⃣ CSS Check:');
    if ($modal.length > 0) {
        var modal = $modal[0];
        var computed = window.getComputedStyle(modal);
        console.log('   Modal computed styles:', {
            display: computed.display,
            visibility: computed.visibility,
            opacity: computed.opacity,
            zIndex: computed.zIndex,
            position: computed.position,
            top: computed.top,
            left: computed.left,
            transform: computed.transform
        });
    }
    
    // 8. Test Modal Functions
    console.log('\n8️⃣ Test Modal Functions:');
    console.log('   Run these commands to test:');
    console.log('   - Open modal: window.testOpenModal()');
    console.log('   - Close modal: window.testCloseModal()');
    
    // Create test functions - Make sure they're always available
    if (typeof window.testOpenModal === 'undefined') {
        window.testOpenModal = function() {
            console.log('[TEST] Opening modal...');
            try {
                if (window.ModalUtils && typeof window.ModalUtils.open === 'function') {
                    window.ModalUtils.open('periodModal');
                    console.log('[TEST] Used ModalUtils.open');
                } else {
                    var $modal = $('#periodModal');
                    var $overlay = $('#modal-overlay');
                    if ($modal.length && $overlay.length) {
                        $modal.addClass('active');
                        $overlay.addClass('active');
                        $('body').css('overflow', 'hidden');
                        console.log('[TEST] Used jQuery to add active class');
                    } else {
                        console.error('[TEST] Modal or overlay not found!');
                        return false;
                    }
                }
                setTimeout(function() {
                    var $modal = $('#periodModal');
                    console.log('[TEST] Modal active:', $modal.hasClass('active'));
                    console.log('[TEST] Modal visible:', $modal.is(':visible'));
                    console.log('[TEST] Modal display:', $modal.css('display'));
                }, 100);
                return true;
            } catch (error) {
                console.error('[TEST] Error opening modal:', error);
                return false;
            }
        };
    }
    
    if (typeof window.testCloseModal === 'undefined') {
        window.testCloseModal = function() {
            console.log('[TEST] Closing modal...');
            try {
                if (window.ModalUtils && typeof window.ModalUtils.closeAll === 'function') {
                    window.ModalUtils.closeAll();
                    console.log('[TEST] Used ModalUtils.closeAll');
                } else {
                    var $modal = $('#periodModal');
                    var $overlay = $('#modal-overlay');
                    if ($modal.length && $overlay.length) {
                        $modal.removeClass('active');
                        $overlay.removeClass('active');
                        $('body').css('overflow', '');
                        console.log('[TEST] Used jQuery to remove active class');
                    } else {
                        console.error('[TEST] Modal or overlay not found!');
                        return false;
                    }
                }
                setTimeout(function() {
                    var $modal = $('#periodModal');
                    console.log('[TEST] Modal active:', $modal.hasClass('active'));
                }, 100);
                return true;
            } catch (error) {
                console.error('[TEST] Error closing modal:', error);
                return false;
            }
        };
    }
    
    // 9. Kiểm tra Network
    console.log('\n9️⃣ Network Check:');
    console.log('   Check Network tab for API requests:');
    console.log('   - GET /api-edu/registration-periods');
    console.log('   - GET /api-edu/registration-periods/active');
    console.log('   - GET /api-edu/academic-years');
    
    // 10. Summary
    console.log('\n========================================');
    console.log('📋 SUMMARY');
    console.log('========================================');
    var issues = [];
    
    if (typeof $ === 'undefined') issues.push('❌ jQuery not loaded');
    if (typeof angular === 'undefined') issues.push('❌ AngularJS not loaded');
    if ($modal.length === 0) issues.push('❌ Modal element not found');
    if ($overlay.length === 0) issues.push('❌ Overlay element not found');
    if (createButton === null) issues.push('❌ Create button not found');
    
    if (issues.length === 0) {
        console.log('✅ All checks passed!');
    } else {
        console.log('⚠️ Issues found:');
        issues.forEach(function(issue) {
            console.log('   ' + issue);
        });
    }
    
    console.log('\n💡 Quick fixes:');
    console.log('   - Test open modal: window.testOpenModal()');
    console.log('   - Test close modal: window.testCloseModal()');
    console.log('   - Force close: $("#periodModal").removeClass("active"); $("#modal-overlay").removeClass("active");');
    console.log('========================================\n');
    
    return {
        modal: $modal.length > 0 ? $modal[0] : null,
        overlay: $overlay.length > 0 ? $overlay[0] : null,
        button: createButton,
        testOpen: window.testOpenModal,
        testClose: window.testCloseModal
    };
})();

