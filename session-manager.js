// =============================================
// Session Management for KV Feedback Portal
// Handles user authentication persistence
// =============================================

// Session management configuration
const SESSION_CONFIG = {
    userKey: 'currentUsername',
    sessionKey: 'sessionToken',
    redirectKey: 'intendedDestination',
    lastPageKey: 'lastVisitedPage',
    loginPath: 'index.html',
    defaultDashboard: 'dashboard.html'
};

// Session Manager Object
const SessionManager = {
    
    // Check if user is currently logged in
    isLoggedIn() {
        const username = sessionStorage.getItem(SESSION_CONFIG.userKey) || localStorage.getItem(SESSION_CONFIG.userKey);
        const sessionToken = sessionStorage.getItem(SESSION_CONFIG.sessionKey) || localStorage.getItem(SESSION_CONFIG.sessionKey);
        return !!(username && username !== 'Guest');
    },
    
    // Get current user information
    getCurrentUser() {
        return {
            username: sessionStorage.getItem(SESSION_CONFIG.userKey) || localStorage.getItem(SESSION_CONFIG.userKey),
            sessionToken: sessionStorage.getItem(SESSION_CONFIG.sessionKey) || localStorage.getItem(SESSION_CONFIG.sessionKey)
        };
    },
    
    // Store user session after successful login
    setUserSession(username, sessionToken = null) {
        // Persist in both sessionStorage and localStorage
        sessionStorage.setItem(SESSION_CONFIG.userKey, username);
        localStorage.setItem(SESSION_CONFIG.userKey, username);
        if (sessionToken) {
            sessionStorage.setItem(SESSION_CONFIG.sessionKey, sessionToken);
            localStorage.setItem(SESSION_CONFIG.sessionKey, sessionToken);
        }
        console.log('✅ User session stored (persistent):', username);
    },
    
    // Track last visited page for return visits
    setLastVisitedPage(page = null) {
        const currentPath = page || window.location.pathname;
        const currentPage = currentPath.split('/').pop() || 'index.html';
        
        // Only track protected pages (not login/public pages)
        const protectedPages = ['dashboard.html', 'feedbacks.html', 'my-feedbacks.html', 'post-feedback.html', 'post-anonymous.html'];
        
        if (protectedPages.includes(currentPage)) {
            // Persist in both storages
            sessionStorage.setItem(SESSION_CONFIG.lastPageKey, currentPage);
            localStorage.setItem(SESSION_CONFIG.lastPageKey, currentPage);
            console.log('📍 Last visited page stored (persistent):', currentPage);
        }
    },
    
    // Get last visited page
    getLastVisitedPage() {
        return sessionStorage.getItem(SESSION_CONFIG.lastPageKey) || localStorage.getItem(SESSION_CONFIG.lastPageKey);
    },
    
    // Clear last visited page
    clearLastVisitedPage() {
        sessionStorage.removeItem(SESSION_CONFIG.lastPageKey);
        localStorage.removeItem(SESSION_CONFIG.lastPageKey);
    },
    
    // Clear user session (logout)
    clearSession() {
        // Clear from both storages
        sessionStorage.removeItem(SESSION_CONFIG.userKey);
        localStorage.removeItem(SESSION_CONFIG.userKey);
        sessionStorage.removeItem(SESSION_CONFIG.sessionKey);
        localStorage.removeItem(SESSION_CONFIG.sessionKey);
        sessionStorage.removeItem(SESSION_CONFIG.redirectKey);
        sessionStorage.removeItem(SESSION_CONFIG.lastPageKey);
        localStorage.removeItem(SESSION_CONFIG.lastPageKey);
        sessionStorage.removeItem('loginRedirect');
        localStorage.removeItem('loginRedirect');
        localStorage.removeItem('feedbackCooldownEnd');
        console.log('🚪 User session cleared');
    },
    
    // Store intended destination before redirecting to login
    setIntendedDestination(path = null) {
        const destination = path || window.location.pathname + window.location.search;
        sessionStorage.setItem(SESSION_CONFIG.redirectKey, destination);
        console.log('📍 Intended destination stored:', destination);
    },
    
    // Get and clear intended destination
    getAndClearIntendedDestination() {
        const destination = sessionStorage.getItem(SESSION_CONFIG.redirectKey);
        sessionStorage.removeItem(SESSION_CONFIG.redirectKey);
        return destination;
    },
    
    // Redirect to login page (from protected pages)
    redirectToLogin() {
        this.setIntendedDestination();
        console.log('🔒 Redirecting to login...');
        window.location.href = SESSION_CONFIG.loginPath;
    },
    
    // Redirect after successful login
    redirectAfterLogin() {
        const intendedDestination = this.getAndClearIntendedDestination();
        let redirectPath = SESSION_CONFIG.defaultDashboard;
        
        // If there was an intended destination, use it
        if (intendedDestination && intendedDestination !== '/' && intendedDestination !== '/index.html') {
            redirectPath = intendedDestination.startsWith('/') ? 
                intendedDestination.substring(1) : intendedDestination;
        } else {
            // Mark this as a login redirect so dashboard redirect happens
            sessionStorage.setItem('loginRedirect', 'true');
        }
        
        console.log('🎯 Redirecting after login to:', redirectPath);
        window.location.href = redirectPath;
    },
    
    // Check if current page requires authentication
    requiresAuth() {
        const currentPath = window.location.pathname;
        const currentPage = currentPath.split('/').pop() || 'index.html';
        
        // Handle GitHub Pages root path
        const isRootPath = currentPath === '/' || currentPath.endsWith('/KV/') || currentPath === '';
        
        const publicPages = ['index.html', 'about.html', ''];
        
        // If it's root path, treat as index.html
        if (isRootPath) {
            return false; // Root path is public (index.html)
        }
        
        return !publicPages.includes(currentPage);
    },
    
    // Initialize session check for current page
    initializePageAuth() {
        const requiresAuth = this.requiresAuth();
        const isLoggedIn = this.isLoggedIn();
        const currentPath = window.location.pathname;
        const currentPage = currentPath.split('/').pop() || 'index.html';
        const isRootPath = currentPath === '/' || currentPath.endsWith('/KV/') || currentPath === '';
        
        console.log('🔐 Page auth check:', {
            currentPath,
            currentPage,
            isRootPath,
            requiresAuth,
            isLoggedIn
        });
        
        // If page requires auth but user is not logged in
        if (requiresAuth && !isLoggedIn) {
            console.log('⚠️ Authentication required - redirecting to login');
            this.redirectToLogin();
            return false;
        }
        
        // Special handling for root URL/index.html when user is logged in
        if (isLoggedIn && (isRootPath || currentPage === 'index.html')) {
            // Check if user has a last visited page
            const lastVisitedPage = this.getLastVisitedPage();
            
            // Check if this is an intended redirect after login
            const hasIntendedDestination = sessionStorage.getItem(SESSION_CONFIG.redirectKey);
            
            // Priority order:
            // 1. Intended destination (from protected page access)
            // 2. Last visited page (return visitor)
            // 3. Dashboard (new login)
            
            if (hasIntendedDestination) {
                // User was redirected here from a protected page - handle normally
                const cameFromLogin = sessionStorage.getItem('loginRedirect') === 'true';
                if (cameFromLogin) {
                    console.log('✅ Login completed with intended destination - will redirect after login');
                    sessionStorage.removeItem('loginRedirect');
                }
            } else if (lastVisitedPage && lastVisitedPage !== 'dashboard.html') {
                // User is returning and has a last visited page (not dashboard)
                console.log('🔄 Returning user - redirecting to last visited page:', lastVisitedPage);
                window.location.href = lastVisitedPage;
                return false;
            } else {
                // Check if this is a fresh login
                const cameFromLogin = sessionStorage.getItem('loginRedirect') === 'true';
                if (cameFromLogin) {
                    console.log('✅ Fresh login completed - redirecting to dashboard');
                    sessionStorage.removeItem('loginRedirect');
                    window.location.href = SESSION_CONFIG.defaultDashboard;
                    return false;
                } else {
                    // User directly navigated to root - let them stay
                    console.log('🏠 User accessing root page directly - allowing access');
                }
            }
        }
        
        // Track current page if user is logged in and on a protected page
        if (isLoggedIn && requiresAuth) {
            this.setLastVisitedPage();
        }
        
        return true;
    },
    
    // Validate session with server (if needed)
    async validateSession() {
        const user = this.getCurrentUser();
        if (!user.username || !user.sessionToken) {
            return false;
        }
        
        try {
            if (window.DatabaseHelper && window.DatabaseHelper.validateSession) {
                const result = await window.DatabaseHelper.validateSession(user.sessionToken);
                if (!result.valid) {
                    console.log('❌ Session validation failed - clearing session');
                    this.clearSession();
                    return false;
                }
                console.log('✅ Session validated successfully');
                return true;
            }
            // If no validation function available, assume valid
            return true;
        } catch (error) {
            console.error('❌ Session validation error:', error);
            return false;
        }
    }
};

// Auto-initialize session management when script loads
document.addEventListener('DOMContentLoaded', function() {
    console.log('🔄 Initializing session management...');
    
    // Sync persistent session into sessionStorage for compatibility
    const persistedUser = localStorage.getItem(SESSION_CONFIG.userKey);
    const persistedToken = localStorage.getItem(SESSION_CONFIG.sessionKey);
    const persistedLastPage = localStorage.getItem(SESSION_CONFIG.lastPageKey);
    
    if (persistedUser && !sessionStorage.getItem(SESSION_CONFIG.userKey)) {
        sessionStorage.setItem(SESSION_CONFIG.userKey, persistedUser);
    }
    if (persistedToken && !sessionStorage.getItem(SESSION_CONFIG.sessionKey)) {
        sessionStorage.setItem(SESSION_CONFIG.sessionKey, persistedToken);
    }
    if (persistedLastPage && !sessionStorage.getItem(SESSION_CONFIG.lastPageKey)) {
        sessionStorage.setItem(SESSION_CONFIG.lastPageKey, persistedLastPage);
    }
    
    // Only run auth check after a short delay to allow other scripts to load
    setTimeout(() => {
        SessionManager.initializePageAuth();
    }, 100);
});

// Track page visits for returning users
window.addEventListener('beforeunload', function() {
    // Update last visited page when user is about to leave
    if (SessionManager.isLoggedIn()) {
        SessionManager.setLastVisitedPage();
    }
});

// Also track when user navigates within the site
window.addEventListener('pagehide', function() {
    // Update last visited page when page is hidden
    if (SessionManager.isLoggedIn()) {
        SessionManager.setLastVisitedPage();
    }
});

// Export for global access
window.SessionManager = SessionManager;
window.SESSION_CONFIG = SESSION_CONFIG;

console.log('📦 Session management loaded');
