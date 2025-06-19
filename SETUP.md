# ShittyDesigns Setup Guide 🎨

This guide will walk you through setting up the ShittyDesigns iOS app with Supabase backend.

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ deployment target
- A Supabase account (free tier available)

## Step 1: Set up Supabase

### 1.1 Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - **Name**: `shittydesigns`
   - **Database Password**: Choose a strong password
   - **Region**: Select closest to your users
5. Click "Create new project"

### 1.2 Set up Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Copy the contents of `Supabase/schema.sql`
3. Paste and run the SQL script
4. This will create all necessary tables and security policies

### 1.3 Configure Storage

1. Go to **Storage** in your Supabase dashboard
2. Create a new bucket called `designs`
3. Set the bucket to public (for image access)
4. Configure RLS policies for the bucket

### 1.4 Get API Keys

1. Go to **Settings** → **API**
2. Copy your:
   - **Project URL**
   - **Anon public key**

## Step 2: Configure iOS App

### 2.1 Update Configuration

1. Open `iOS/ShittyDesigns/ShittyDesignsApp.swift`
2. Replace the placeholder values:
   ```swift
   let supabaseURL = "YOUR_SUPABASE_URL"
   let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
   ```
   With your actual Supabase credentials.

### 2.2 Add Dependencies

1. Open Xcode
2. Go to **File** → **Add Package Dependencies**
3. Add the Supabase Swift package:
   ```
   https://github.com/supabase-community/supabase-swift.git
   ```

### 2.3 Configure Permissions

Add the following to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>ShittyDesigns needs camera access to let you take photos of your designs.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ShittyDesigns needs photo library access to let you select images for your designs.</string>
```

## Step 3: Build and Run

1. Open the project in Xcode
2. Select your target device/simulator
3. Press **Cmd+R** to build and run

## Step 4: Test the App

1. **Sign Up**: Create a new account
2. **Upload**: Try uploading a design with image, title, and tags
3. **Browse**: View the feed of uploaded designs
4. **Interact**: Like and comment on designs
5. **Search**: Use the search and tag filtering features

## Project Structure

```
ShittyDesigns/
├── iOS/                          # iOS App
│   ├── ShittyDesigns/
│   │   ├── ShittyDesignsApp.swift    # App entry point
│   │   ├── Views/                    # UI Views
│   │   │   ├── ContentView.swift
│   │   │   ├── AuthView.swift
│   │   │   ├── MainTabView.swift
│   │   │   ├── FeedView.swift
│   │   │   ├── UploadView.swift
│   │   │   ├── SearchView.swift
│   │   │   ├── ProfileView.swift
│   │   │   └── DesignDetailView.swift
│   │   ├── Models/                   # Data Models
│   │   │   └── Design.swift
│   │   ├── ViewModels/               # Business Logic
│   │   │   ├── AuthViewModel.swift
│   │   │   └── DesignsViewModel.swift
│   │   └── Utils/                    # Utilities
│   │       └── ImagePicker.swift
├── Supabase/                     # Backend Configuration
│   └── schema.sql               # Database schema
└── README.md                    # Project overview
```

## Features Implemented

✅ **Authentication**
- User registration and login
- Session management
- Profile creation

✅ **Design Upload**
- Image picker (camera + photo library)
- Title and description
- Tag system
- Real-time upload to Supabase

✅ **Feed & Discovery**
- Pinterest-style grid layout
- Pull-to-refresh
- Design cards with metadata

✅ **Search & Filtering**
- Text search in titles and descriptions
- Tag-based filtering
- Real-time search results

✅ **User Profiles**
- Personal design gallery
- User statistics
- Settings and logout

✅ **Social Features**
- Like/unlike designs
- Comment system
- Share functionality

✅ **Backend**
- PostgreSQL database with RLS
- Real-time subscriptions
- Image storage
- Automatic count updates

## Troubleshooting

### Common Issues

1. **Build Errors**: Make sure you're using Xcode 15+ and iOS 17+
2. **Supabase Connection**: Verify your API keys are correct
3. **Image Upload**: Check that the `designs` bucket exists and is public
4. **Permissions**: Ensure camera and photo library permissions are configured

### Getting Help

- Check the [Supabase documentation](https://supabase.com/docs)
- Review the [Supabase Swift documentation](https://supabase.com/docs/reference/swift)
- Open an issue in this repository

## Next Steps

Once the basic app is working, consider adding:

- Push notifications for likes/comments
- User following system
- Advanced image editing
- Offline support
- Analytics and insights
- Social sharing integration
- Dark mode support

## Contributing

Feel free to contribute to this project! The goal is to create a fun, inclusive platform where everyone feels comfortable sharing their art, no matter their skill level.

---

**Remember**: The whole point of ShittyDesigns is to celebrate imperfect art! Don't worry about making everything perfect - that's not the point here! 🎨✨ 