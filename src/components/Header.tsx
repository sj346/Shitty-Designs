import React, { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Menu, Search, Bell, User, LogOut, Settings, Palette, Plus, Sparkles } from 'lucide-react'
import { useAuth } from '../contexts/AuthContext'
import ThemeToggle from './ThemeToggle'

interface HeaderProps {
  onMenuClick: () => void
}

const Header: React.FC<HeaderProps> = ({ onMenuClick }) => {
  const { user, signOut } = useAuth()
  const navigate = useNavigate()
  const [showUserMenu, setShowUserMenu] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    if (searchQuery.trim()) {
      navigate(`/search?q=${encodeURIComponent(searchQuery.trim())}`)
      setSearchQuery('')
    }
  }

  const handleSignOut = async () => {
    try {
      await signOut()
      navigate('/')
    } catch (error) {
      console.error('Error signing out:', error)
    }
  }

  return (
    <header className="header">
      <div className="container-modern">
        <div className="flex justify-between items-center h-16">
          {/* Left side */}
          <div className="flex items-center space-x-4">
            <button
              onClick={onMenuClick}
              className="lg:hidden p-2 rounded-2xl hover:bg-accent transition-all duration-300"
            >
              <Menu className="h-6 w-6" />
            </button>

            {/* Logo */}
            <Link to="/" className="flex items-center space-x-3 group">
              <div className="relative">
                <div className="w-10 h-10 bg-gradient-primary rounded-2xl flex items-center justify-center shadow-modern-lg group-hover:shadow-modern-xl transition-all duration-300 group-hover:scale-110">
                  <Palette className="h-5 w-5 text-white" />
                </div>
                <div className="absolute -top-1 -right-1 w-4 h-4 bg-gradient-to-br from-chart-1 to-chart-5 rounded-full flex items-center justify-center animate-pulse">
                  <Sparkles className="h-2 w-2 text-white" />
                </div>
              </div>
              <span className="font-bold text-xl text-foreground hidden sm:block">ShittyDesigns</span>
            </Link>
          </div>

          {/* Search bar */}
          <div className="search-bar">
            <form onSubmit={handleSearch} className="relative">
              <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <Search className="h-5 w-5 text-muted-foreground" />
              </div>
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search for amazing designs..."
                className="search-input"
              />
            </form>
          </div>

          {/* Right side */}
          <div className="flex items-center space-x-3">
            <ThemeToggle />
            
            {user ? (
              <>
                <Link
                  to="/upload"
                  className="hidden sm:flex items-center space-x-2 px-6 py-3 bg-gradient-primary text-white rounded-full hover:shadow-modern-lg transition-all duration-300 hover:scale-105 font-medium"
                >
                  <Plus className="h-4 w-4" />
                  <span>Create</span>
                </Link>

                <button className="p-3 hover:bg-accent rounded-full transition-all duration-300 relative">
                  <Bell className="h-5 w-5" />
                  <span className="absolute top-2 right-2 w-2 h-2 bg-chart-1 rounded-full animate-pulse"></span>
                </button>

                <div className="relative">
                  <button
                    onClick={() => setShowUserMenu(!showUserMenu)}
                    className="flex items-center space-x-3 p-2 hover:bg-accent rounded-full transition-all duration-300"
                  >
                    {user.avatar_url ? (
                      <img
                        src={user.avatar_url}
                        alt={user.username}
                        className="w-8 h-8 avatar"
                      />
                    ) : (
                      <div className="w-8 h-8 bg-gradient-primary rounded-full flex items-center justify-center">
                        <User className="h-4 w-4 text-white" />
                      </div>
                    )}
                  </button>

                  {showUserMenu && (
                    <div className="absolute right-0 mt-2 w-56 glass-card py-2 z-50 animate-slide-up">
                      <div className="px-4 py-3 border-b border-border/50">
                        <p className="font-medium text-foreground">{user.username}</p>
                        <p className="text-sm text-muted-foreground">{user.email}</p>
                      </div>
                      <Link
                        to={`/profile/${user.username}`}
                        className="flex items-center px-4 py-3 text-sm hover:bg-accent/50 transition-all duration-300 rounded-2xl mx-2"
                        onClick={() => setShowUserMenu(false)}
                      >
                        <User className="h-4 w-4 mr-3" />
                        Profile
                      </Link>
                      <Link
                        to="/settings"
                        className="flex items-center px-4 py-3 text-sm hover:bg-accent/50 transition-all duration-300 rounded-2xl mx-2"
                        onClick={() => setShowUserMenu(false)}
                      >
                        <Settings className="h-4 w-4 mr-3" />
                        Settings
                      </Link>
                      <hr className="my-2 border-border/50" />
                      <button
                        onClick={handleSignOut}
                        className="flex items-center w-full px-4 py-3 text-sm text-destructive hover:bg-destructive/10 transition-all duration-300 rounded-2xl mx-2"
                      >
                        <LogOut className="h-4 w-4 mr-3" />
                        Sign Out
                      </button>
                    </div>
                  )}
                </div>
              </>
            ) : (
              <Link
                to="/auth"
                className="px-6 py-3 bg-gradient-primary text-white rounded-full hover:shadow-modern-lg transition-all duration-300 hover:scale-105 font-medium"
              >
                Sign In
              </Link>
            )}
          </div>
        </div>
      </div>
    </header>
  )
}

export default Header