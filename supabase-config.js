// =============================================
// Supabase Configuration
// PM SHRI KV Barrackpore Feedback Portal
// =============================================

// TODO: Replace with your actual Supabase credentials
const SUPABASE_CONFIG = {
    url: 'https://oymthdbwemelojniclig.supabase.co', // e.g., 'https://xxxxx.supabase.co'
    apiKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im95bXRoZGJ3ZW1lbG9qbmljbGlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNjk3MjgsImV4cCI6MjA3MjY0NTcyOH0.Tl-vW4L1uDAxPmmfmTP4zkrSyjpJio4Mjt0hxgyXlHI', // Your anon/public API key
    
    // Optional: Service role key for admin operations (keep secure!)
    // serviceRoleKey: 'YOUR_SERVICE_ROLE_KEY_HERE'
};

// Initialize Supabase client
let supabase = null;

// Function to initialize Supabase (will be called after loading the library)
function initializeSupabase() {
    if (supabase === null && window.supabase) {
        console.log('🚀 Initializing Supabase connection...');
        
        try {
            supabase = window.supabase.createClient(
                SUPABASE_CONFIG.url,
                SUPABASE_CONFIG.apiKey
            );
            
            console.log('✅ Supabase client initialized successfully');
            console.log('🔗 Supabase URL:', SUPABASE_CONFIG.url);
            return true;
        } catch (error) {
            console.error('❌ Failed to initialize Supabase:', error);
            return false;
        }
    }
    return supabase !== null;
}

// Database helper functions
const DatabaseHelper = {
    
    // Test database connection
    async testConnection() {
        try {
            if (!supabase) {
                console.error('❌ Supabase client not initialized');
                return false;
            }
            
            // Simple test - try to query users table
            const { data, error } = await supabase
                .from('users')
                .select('id')
                .limit(1);
            
            if (error) {
                console.error('❌ Database connection failed:', error.message);
                return false;
            }
            
            console.log('✅ Database connection successful');
            return true;
        } catch (error) {
            console.error('❌ Database connection error:', error);
            return false;
        }
    },

    // Hash password using built-in crypto (basic implementation)
    async hashPassword(password) {
        try {
            // Use Web Crypto API for password hashing
            const encoder = new TextEncoder();
            const data = encoder.encode(password + 'KV_SALT_2024'); // Add salt
            const hashBuffer = await crypto.subtle.digest('SHA-256', data);
            const hashArray = Array.from(new Uint8Array(hashBuffer));
            const hashHex = hashArray.map(byte => byte.toString(16).padStart(2, '0')).join('');
            return hashHex;
        } catch (error) {
            console.error('❌ Password hashing failed:', error);
            throw new Error('Password hashing failed');
        }
    },

    // Create new user account
    async createUser(userData) {
        try {
            console.log('📝 Creating new user account...');
            
            // Hash the password
            const hashedPassword = await this.hashPassword(userData.password);
            
            // Check if username already exists
            const { data: existingUser, error: checkError } = await supabase
                .from('users')
                .select('username')
                .eq('username', userData.username)
                .maybeSingle();
            
            if (existingUser && !checkError) {
                throw new Error('Username already exists');
            }
            
            // Insert new user
            const { data, error } = await supabase
                .from('users')
                .insert([
                    {
                        username: userData.username,
                        password_hash: hashedPassword,
                        full_name: userData.full_name || userData.username,
                        user_type: userData.user_type || 'student',
                        class_section: userData.class_section || null,
                        roll_number: userData.roll_number || null
                    }
                ])
                .select()
                .single();
            
            if (error) {
                console.error('❌ User creation failed:', error);
                throw new Error(`Failed to create account: ${error.message}`);
            }
            
            console.log('✅ User account created successfully:', data.username);
            return {
                success: true,
                user: {
                    id: data.id,
                    username: data.username,
                    user_type: data.user_type,
                    created_at: data.created_at
                },
                message: 'Account created successfully!'
            };
            
        } catch (error) {
            console.error('❌ Create user error:', error);
            return {
                success: false,
                error: error.message || 'Failed to create account'
            };
        }
    },

    // Authenticate user login
    async authenticateUser(username, password) {
        try {
            console.log('🔐 Authenticating user login...');
            
            // Hash the provided password
            const hashedPassword = await this.hashPassword(password);
            
            // Find user with matching credentials
            const { data: user, error } = await supabase
                .from('users')
                .select('id, username, user_type, full_name, is_active, last_login')
                .eq('username', username)
                .eq('password_hash', hashedPassword)
                .eq('is_active', true)
                .single();
            
            if (error || !user) {
                console.log('❌ Login failed: Invalid credentials');
                return {
                    success: false,
                    error: 'Invalid username or password'
                };
            }
            
            // Update last login timestamp
            await supabase
                .from('users')
                .update({ last_login: new Date().toISOString() })
                .eq('id', user.id);
            
            console.log('✅ User authenticated successfully:', user.username);
            return {
                success: true,
                user: {
                    id: user.id,
                    username: user.username,
                    user_type: user.user_type,
                    full_name: user.full_name
                },
                message: `Welcome back, ${user.username}!`
            };
            
        } catch (error) {
            console.error('❌ Authentication error:', error);
            return {
                success: false,
                error: 'Login failed. Please try again.'
            };
        }
    },

    // Create user session using SQL function
    async createSession(userId) {
        try {
            console.log('🔑 Creating user session...');
            
            // Generate secure session token
            const sessionToken = crypto.randomUUID();
            
            // Use SQL function to create session
            const { data, error } = await supabase
                .rpc('create_user_session', {
                    p_user_id: userId,
                    p_session_token: sessionToken,
                    p_user_agent: navigator.userAgent,
                    p_ip_address: null, // Could be populated from server
                    p_expires_hours: 24
                });
            
            if (error) {
                console.error('❌ Session creation failed:', error);
                return null;
            }
            
            console.log('✅ Session created successfully');
            return sessionToken;
            
        } catch (error) {
            console.error('❌ Session creation error:', error);
            return null;
        }
    },

    // Validate existing session using SQL function
    async validateSession(sessionToken) {
        try {
            console.log('🔍 Validating session...');
            
            // Use SQL function for session validation
            const { data, error } = await supabase
                .rpc('validate_session_and_get_user', {
                    p_session_token: sessionToken
                });
            
            if (error || !data || data.length === 0) {
                console.log('❌ Session validation failed or no data');
                return { valid: false };
            }
            
            const session = data[0];
            
            if (!session.is_valid) {
                console.log('❌ Session is invalid or expired');
                return { valid: false, reason: 'invalid' };
            }
            
            console.log('✅ Session validated successfully for user:', session.username);
            return {
                valid: true,
                user: {
                    id: session.user_id,
                    username: session.username,
                    user_type: session.user_type,
                    full_name: session.full_name
                },
                expires_at: session.expires_at,
                time_remaining: session.time_remaining
            };
        } catch (error) {
            console.error('❌ Session validation error:', error);
            return { valid: false };
        }
    },

    // Logout user using SQL function
    async logout(sessionToken) {
        try {
            console.log('🚪 Logging out user...');
            
            if (sessionToken) {
                // Use SQL function to invalidate session
                const { data, error } = await supabase
                    .rpc('invalidate_session', {
                        p_session_token: sessionToken
                    });
                
                if (error) {
                    console.error('❌ Session invalidation failed:', error);
                }
            }
            
            console.log('✅ User logged out successfully');
            return true;
        } catch (error) {
            console.error('❌ Logout error:', error);
            return false;
        }
    },

    // Submit feedback to database
    async submitFeedback(feedbackData) {
        try {
            console.log('📝 Submitting feedback...');
            
            const { data, error } = await supabase
                .from('feedback_submissions')
                .insert([
                    {
                        username: feedbackData.username,
                        feedback_text: feedbackData.text,
                        is_anonymous: feedbackData.isAnonymous,
                        character_count: feedbackData.text.length
                    }
                ])
                .select()
                .single();
            
            if (error) {
                console.error('❌ Feedback submission failed:', error);
                return {
                    success: false,
                    error: error.message
                };
            }
            
            console.log('✅ Feedback submitted successfully');
            return {
                success: true,
                data: data,
                message: 'Feedback posted successfully!'
            };
            
        } catch (error) {
            console.error('❌ Feedback submission error:', error);
            return {
                success: false,
                error: 'Failed to submit feedback'
            };
        }
    },

    // Get today's feedbacks
    async getTodaysFeedbacks() {
        try {
            console.log('📚 Fetching today\'s feedbacks...');
            
            // Get today's date in YYYY-MM-DD format
            const today = new Date().toISOString().split('T')[0];
            console.log('📅 Fetching feedbacks for date:', today);
            
            const { data, error } = await supabase
                .from('feedback_submissions')
                .select('*')
                .eq('submission_date', today)
                // Removed is_approved filter to show all feedbacks
                .order('created_at', { ascending: false });  // Use created_at instead of submission_time
            
            if (error) {
                console.error('❌ Failed to fetch feedbacks:', error);
                return {
                    success: false,
                    error: error.message,
                    feedbacks: []
                };
            }
            
            console.log(`✅ Fetched ${data ? data.length : 0} feedbacks`);
            
            // If no feedbacks for today, try getting all recent feedbacks
            if (!data || data.length === 0) {
                console.log('📋 No feedbacks for today, fetching all recent feedbacks...');
                
                const { data: allData, error: allError } = await supabase
                    .from('feedback_submissions')
                    .select('*')
                    .order('created_at', { ascending: false })
                    .limit(20);  // Get last 20 feedbacks
                
                if (allError) {
                    console.error('❌ Failed to fetch all feedbacks:', allError);
                    return {
                        success: false,
                        error: allError.message,
                        feedbacks: []
                    };
                }
                
                console.log(`✅ Fetched ${allData ? allData.length : 0} recent feedbacks`);
                return {
                    success: true,
                    feedbacks: allData || []
                };
            }
            
            return {
                success: true,
                feedbacks: data
            };
            
        } catch (error) {
            console.error('❌ Error fetching feedbacks:', error);
            return {
                success: false,
                error: 'Failed to load feedbacks',
                feedbacks: []
            };
        }
    },

    // Get all feedbacks with comment counts (optimized)
    async getAllFeedbacksWithComments() {
        try {
            console.log('📚 Fetching all feedbacks with comment counts...');
            
            const { data, error } = await supabase
                .from('feedback_submissions')
                .select(`
                    *,
                    comment_count:feedback_comments(count)
                `)
                .order('created_at', { ascending: false })
                .limit(50);
            
            if (error) {
                console.error('❌ Failed to fetch feedbacks with comments:', error);
                return {
                    success: false,
                    error: error.message,
                    feedbacks: []
                };
            }
            
            // Process the data to include comment counts
            const processedFeedbacks = data?.map(feedback => ({
                ...feedback,
                comment_count: feedback.comment_count?.[0]?.count || 0
            })) || [];
            
            console.log(`✅ Fetched ${processedFeedbacks.length} feedbacks with comment counts`);
            return {
                success: true,
                feedbacks: processedFeedbacks
            };
            
        } catch (error) {
            console.error('❌ Error fetching feedbacks with comments:', error);
            return {
                success: false,
                error: 'Failed to load feedbacks',
                feedbacks: []
            };
        }
    },

    // Get feedbacks for a specific user
    async getUserFeedbacks(username) {
        try {
            console.log(`📚 Fetching feedbacks for user: ${username}`);
            
            const { data, error } = await supabase
                .from('feedback_submissions')
                .select('*')
                .eq('username', username)
                .order('created_at', { ascending: false });
            
            if (error) {
                console.error('❌ Failed to fetch user feedbacks:', error);
                return {
                    success: false,
                    error: error.message,
                    feedbacks: []
                };
            }
            
            console.log(`✅ Fetched ${data ? data.length : 0} feedbacks for user ${username}`);
            return {
                success: true,
                feedbacks: data || []
            };
            
        } catch (error) {
            console.error('❌ Error fetching user feedbacks:', error);
            return {
                success: false,
                error: 'Failed to load user feedbacks',
                feedbacks: []
            };
        }
    },

    // Report a feedback
    async reportFeedback(feedbackId) {
        try {
            console.log('🚩 Reporting feedback...');
            
            // First get current report count
            const { data: feedback, error: fetchError } = await supabase
                .from('feedback_submissions')
                .select('report_count')
                .eq('id', feedbackId)
                .single();
            
            if (fetchError) {
                throw fetchError;
            }
            
            // Update report count and flag
            const newReportCount = (feedback.report_count || 0) + 1;
            const { error: updateError } = await supabase
                .from('feedback_submissions')
                .update({
                    report_count: newReportCount,
                    is_reported: true
                })
                .eq('id', feedbackId);
            
            if (updateError) {
                throw updateError;
            }
            
            console.log('✅ Feedback reported successfully');
            return { success: true };
            
        } catch (error) {
            console.error('❌ Error reporting feedback:', error);
            return { success: false, error: error.message };
        }
    },

    // Submit anonymous complaint
    async submitComplaint(complaintText) {
        try {
            console.log('📝 Submitting anonymous complaint...');
            if (!supabase) {
                console.error('❌ Supabase client not initialized');
                return { success: false, error: 'Database not ready' };
            }
            const { data, error } = await supabase
                .from('anonymous_complaints')
                .insert([
                    {
                        complaint_text: complaintText
                    }
                ]);
            
            if (error) {
                console.error('❌ Complaint submission failed:', error);
                return { success: false, error: error.message };
            }
            
            console.log('✅ Complaint submitted successfully');
            return { success: true, data, message: 'Complaint submitted anonymously!' };
        } catch (error) {
            console.error('❌ Complaint submission error:', error);
            return { success: false, error: 'Failed to submit complaint' };
        }
    },

    // ============================================
    // COMMENT SYSTEM FUNCTIONS
    // ============================================

    // Submit a comment to a feedback
    async submitComment(commentData) {
        try {
            console.log('💬 Submitting comment...');
            
            if (!supabase) {
                console.error('❌ Supabase client not initialized');
                return { success: false, error: 'Database not ready' };
            }

            const { data, error } = await supabase
                .from('feedback_comments')
                .insert([
                    {
                        feedback_id: commentData.feedbackId,
                        username: commentData.username,
                        comment_text: commentData.text,
                        is_anonymous: commentData.isAnonymous,
                        character_count: commentData.text.length
                    }
                ])
                .select()
                .single();
            
            if (error) {
                console.error('❌ Comment submission failed:', error);
                return {
                    success: false,
                    error: error.message
                };
            }
            
            console.log('✅ Comment submitted successfully');
            return {
                success: true,
                data: data,
                message: 'Comment posted successfully!'
            };
            
        } catch (error) {
            console.error('❌ Comment submission error:', error);
            return {
                success: false,
                error: 'Failed to submit comment'
            };
        }
    },

    // Get comments for a specific feedback
    async getCommentsForFeedback(feedbackId) {
        try {
            console.log(`💬 Fetching comments for feedback: ${feedbackId}`);
            
            if (!supabase) {
                console.error('❌ Supabase client not initialized');
                return { success: false, error: 'Database not ready', comments: [] };
            }

            const { data, error } = await supabase
                .from('feedback_comments')
                .select('*')
                .eq('feedback_id', feedbackId)
                .eq('is_approved', true)
                .order('created_at', { ascending: true });
            
            if (error) {
                console.error('❌ Failed to fetch comments:', error);
                return {
                    success: false,
                    error: error.message,
                    comments: []
                };
            }
            
            console.log(`✅ Fetched ${data ? data.length : 0} comments`);
            return {
                success: true,
                comments: data || []
            };
            
        } catch (error) {
            console.error('❌ Error fetching comments:', error);
            return {
                success: false,
                error: 'Failed to load comments',
                comments: []
            };
        }
    },

    // Get comment count for a specific feedback
    async getCommentCount(feedbackId) {
        try {
            const { count, error } = await supabase
                .from('feedback_comments')
                .select('*', { count: 'exact', head: true })
                .eq('feedback_id', feedbackId)
                .eq('is_approved', true);
            
            if (error) {
                console.error('❌ Failed to get comment count:', error);
                return 0;
            }
            
            return count || 0;
            
        } catch (error) {
            console.error('❌ Error getting comment count:', error);
            return 0;
        }
    },

    // Report a comment
    async reportComment(commentId) {
        try {
            console.log('🚩 Reporting comment...');
            
            // First get current report count
            const { data: comment, error: fetchError } = await supabase
                .from('feedback_comments')
                .select('report_count')
                .eq('id', commentId)
                .single();
            
            if (fetchError) {
                throw fetchError;
            }
            
            // Update report count and flag
            const newReportCount = (comment.report_count || 0) + 1;
            const { error: updateError } = await supabase
                .from('feedback_comments')
                .update({
                    report_count: newReportCount,
                    is_reported: true
                })
                .eq('id', commentId);
            
            if (updateError) {
                throw updateError;
            }
            
            console.log('✅ Comment reported successfully');
            return { success: true, message: 'Comment reported successfully' };
            
        } catch (error) {
            console.error('❌ Error reporting comment:', error);
            return { success: false, error: error.message };
        }
    },

    // Get all comments for a user
    async getUserComments(username) {
        try {
            console.log(`💬 Fetching comments for user: ${username}`);
            
            const { data, error } = await supabase
                .from('feedback_comments')
                .select(`
                    *,
                    feedback_submissions:feedback_id (
                        id,
                        feedback_text,
                        username,
                        created_at
                    )
                `)
                .eq('username', username)
                .order('created_at', { ascending: false });
            
            if (error) {
                console.error('❌ Failed to fetch user comments:', error);
                return {
                    success: false,
                    error: error.message,
                    comments: []
                };
            }
            
            console.log(`✅ Fetched ${data ? data.length : 0} comments for user ${username}`);
            return {
                success: true,
                comments: data || []
            };
            
        } catch (error) {
            console.error('❌ Error fetching user comments:', error);
            return {
                success: false,
                error: 'Failed to load user comments',
                comments: []
            };
        }
    },

    // Delete a comment (only by the author)
    async deleteComment(commentId, username) {
        try {
            console.log('🗑️ Deleting comment...');
            
            // First verify the comment belongs to the user
            const { data: comment, error: fetchError } = await supabase
                .from('feedback_comments')
                .select('username, comment_text')
                .eq('id', commentId)
                .single();
            
            if (fetchError) {
                console.error('❌ Error fetching comment for deletion:', fetchError);
                return { success: false, error: 'Comment not found' };
            }
            
            // Check if user owns the comment
            if (comment.username !== username) {
                console.error('❌ User does not own this comment');
                return { success: false, error: 'You can only delete your own comments' };
            }
            
            // Delete the comment
            const { error } = await supabase
                .from('feedback_comments')
                .delete()
                .eq('id', commentId);
            
            if (error) {
                console.error('❌ Error deleting comment:', error);
                return { success: false, error: error.message };
            }
            
            console.log('✅ Comment deleted successfully');
            return { success: true, message: 'Comment deleted successfully' };
            
        } catch (error) {
            console.error('❌ Error deleting comment:', error);
            return { success: false, error: error.message };
        }
    }
};

// Export for global access
window.DatabaseHelper = DatabaseHelper;
window.SUPABASE_CONFIG = SUPABASE_CONFIG;

console.log('📦 Supabase configuration loaded');

// Auto-initialize if supabase is already available
if (window.supabase) {
    initializeSupabase();
}
