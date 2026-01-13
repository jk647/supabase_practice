# 🎯 Supabase Practice Project - Task Manager

A Flutter-based task management application built to practice and learn **Supabase** features, **PostgreSQL**, and backend integration.

## 📚 What I Learned & Practiced

This project was created as a hands-on learning experience with Supabase. Here's what I practiced:

### 🔐 Authentication
- **Email/Password Authentication** - Traditional sign-up and login
- **Google OAuth Integration** - Social authentication with Google Sign-In
- **Auth State Management** - Real-time authentication state tracking
- **Session Management** - Persistent user sessions

### 🗄️ PostgreSQL Database
- **Table Creation** - Created `tasks` table with proper schema
- **Row Level Security (RLS)** - Implemented security policies to ensure users can only access their own data
- **Foreign Keys & Relationships** - Connected tasks to users via `user_id` references
- **Indexes** - Added database indexes for query optimization
- **Triggers** - Auto-update timestamps using PostgreSQL triggers

### ⚡ PostgreSQL Functions (RPC)
Created and used three custom PostgreSQL functions:

1. **`get_task_statistics`** - Calculates task analytics
   - Total tasks, completed tasks, pending tasks
   - Completion rate percentage
   - Tasks grouped by category
   
2. **`bulk_complete_tasks`** - Batch operations
   - Mark multiple tasks as completed in one operation
   
3. **`archive_old_completed_tasks`** - Data maintenance
   - Clean up old completed tasks

### 📦 Storage
- **File Upload** - Profile picture/avatar uploads
- **Bucket Management** - Created and configured `avatars` bucket
- **Storage Policies** - Set up public access for avatar images
- **File Metadata** - Track file owners and timestamps

### 🎨 Features Implemented

#### Task Management
- ✅ Create, read, update, delete (CRUD) operations
- ✅ Task categories (Work, Personal, Shopping, Health)
- ✅ Task completion status
- ✅ Pin important tasks
- ✅ Search functionality
- ✅ Bulk complete all tasks

#### Real-time Statistics
- 📊 Total tasks count
- ✅ Completed tasks count
- ⏳ Pending tasks count
- 📈 Completion rate percentage
- 🏷️ Category breakdown

#### User Profile
- 👤 Display user information
- 🖼️ Profile picture/avatar management
- 📧 Email display

## 🛠️ Tech Stack

- **Flutter** - UI Framework
- **Supabase** - Backend-as-a-Service
  - Authentication
  - PostgreSQL Database
  - Storage
  - Real-time subscriptions
- **Google Sign-In** - OAuth provider

### Authentication
- Login screen with email/password and Google OAuth
- Sign-up screen with user registration

### Home Screen
- Task list with search and filtering
- Real-time statistics dashboard
- Category chips for filtering
- Floating action button for adding tasks

### Features
- Task cards with completion, pin, and delete actions
- Statistics showing total, done, and pending tasks
- Profile management with avatar upload

## 🗂️ Project Structure

```
lib/
├── config/
│   └── supabase_config.dart          # Supabase credentials
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # Login UI
│   │   ├── signup_screen.dart        # Registration UI
│   │   └── services/
│   │       └── auth_services.dart    # Authentication logic
│   ├── home/
│   │   ├── home_screen.dart          # Main task screen
│   │   ├── models/
│   │   │   └── task_model.dart       # Task data model
│   │   ├── services/
│   │   │   └── task_service.dart     # Task CRUD operations
│   │   └── widgets/
│   │       ├── task_card.dart        # Task item widget
│   │       └── statistics_widget.dart # Stats display
│   └── profile/
│       └── profile_screen.dart       # User profile
└── main.dart                          # App entry point
```

## 🔑 Key Learnings

### Database Design
- Learned how to structure relational data
- Implemented proper foreign key relationships
- Used `CASCADE DELETE` for data integrity

### Security
- Configured Row Level Security policies
- Ensured users can only access their own data
- Used `SECURITY DEFINER` for functions that need elevated privileges

### Backend Functions
- Created reusable PostgreSQL functions
- Used `DECLARE` and `BEGIN...END` blocks
- Worked with JSON data types and aggregation

### Real-time Features
- Implemented auth state change listeners
- Refreshed data after operations
- Maintained UI state consistency

### File Management
- Uploaded files to Supabase Storage
- Managed file metadata and ownership
- Configured storage bucket policies


### RLS Policies
- `Users can view their own tasks` - SELECT policy
- `Users can insert their own tasks` - INSERT policy
- `Users can update their own tasks` - UPDATE policy
- `Users can delete their own tasks` - DELETE policy

## 🚀 What I Achieved

Through this practice project, I successfully:

1. ✅ Connected Flutter app to Supabase backend
2. ✅ Implemented complete authentication flow
3. ✅ Designed and created PostgreSQL database schema
4. ✅ Wrote custom PostgreSQL functions for complex queries
5. ✅ Implemented Row Level Security for data protection
6. ✅ Managed file uploads and storage
7. ✅ Built real-time reactive UI with proper state management
8. ✅ Created a complete CRUD application with advanced features



**Note:** This is a practice project created for learning purposes. The focus was on understanding Supabase features, PostgreSQL, and backend integration rather than production-ready code.

---

Made with ❤️ while learning Supabase