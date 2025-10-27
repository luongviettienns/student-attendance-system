/**
 * Sidebar Toggle và Responsive Handler
 */
(function() {
    'use strict';
    
    // Wait for DOM to be ready
    document.addEventListener('DOMContentLoaded', function() {
        initSidebar();
    });
    
    // Also initialize when route changes (for AngularJS)
    if (window.angular) {
        angular.element(document).ready(function() {
            setTimeout(initSidebar, 100);
        });
    }
    
    function initSidebar() {
        const menuToggle = document.querySelector('.menu-toggle');
        const sidebar = document.querySelector('.sidebar');
        const mainContent = document.querySelector('.main-content');
        
        if (!menuToggle || !sidebar || !mainContent) {
            // Retry after a short delay
            setTimeout(initSidebar, 200);
            return;
        }
        
        // Create overlay for mobile
        let overlay = document.querySelector('.sidebar-overlay');
        if (!overlay) {
            overlay = document.createElement('div');
            overlay.className = 'sidebar-overlay';
            document.body.appendChild(overlay);
        }
        
        // Toggle sidebar function
        function toggleSidebar() {
            const isCollapsed = sidebar.classList.contains('collapsed');
            const isMobile = window.innerWidth < 1024;
            
            if (isCollapsed) {
                // Open sidebar
                sidebar.classList.remove('collapsed');
                mainContent.classList.remove('expanded');
                // Only show overlay on mobile
                if (isMobile) {
                    overlay.classList.add('active');
                }
            } else {
                // Close sidebar
                sidebar.classList.add('collapsed');
                mainContent.classList.add('expanded');
                overlay.classList.remove('active');
            }
        }
        
        // Menu toggle button click
        menuToggle.addEventListener('click', function(e) {
            e.stopPropagation();
            toggleSidebar();
        });
        
        // Overlay click - close sidebar on mobile
        overlay.addEventListener('click', function() {
            if (window.innerWidth < 1024) {
                sidebar.classList.add('collapsed');
                mainContent.classList.add('expanded');
                overlay.classList.remove('active');
            }
        });
        
        // Handle window resize
        let resizeTimer;
        window.addEventListener('resize', function() {
            clearTimeout(resizeTimer);
            resizeTimer = setTimeout(function() {
                handleResize();
            }, 250);
        });
        
        function handleResize() {
            const width = window.innerWidth;
            
            if (width >= 1024) {
                // Desktop - show sidebar by default
                sidebar.classList.remove('collapsed');
                mainContent.classList.remove('expanded');
                overlay.classList.remove('active');
            } else {
                // Mobile - hide sidebar by default
                sidebar.classList.add('collapsed');
                mainContent.classList.add('expanded');
                overlay.classList.remove('active');
            }
        }
        
        // Initialize based on screen size
        handleResize();
    }
    
    // Re-initialize on route change for AngularJS
    if (window.angular) {
        angular.module('adminApp').run(['$rootScope', function($rootScope) {
            $rootScope.$on('$routeChangeSuccess', function() {
                setTimeout(initSidebar, 100);
            });
        }]);
    }
})();

