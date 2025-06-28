import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import { Home, Search, Upload, User, Palette, X, TrendingUp, Heart, Bookmark, Sparkles, Users, BarChart3 } from 'lucide-react'
import { useAuth } from '../contexts/AuthContext'

interface SidebarProps {
  onClose?: () => void
}

const Sidebar: React.FC<SidebarProps> = ({ onClose }) => {
  const location = useLocation()
  const { user } = useAuth()

  const navigation = [
    { name: 'Home', href: '/', icon: Home, description: 'Latest designs' },
    { name: 'Trending', href: '/trending', icon: TrendingUp, description: 'Hot right now' },
    { name: 'Search', href: '/search', icon: Search, description: 'Find anything' },
  ]

  const userNavigation = user ? [
    { name: 'Create', href: '/upload', icon: Upload, description: 'Share your art' },
    { name: 'Liked', href: '/liked', icon: Heart, description: 'Your favorites' },
    { name: 'Saved', href: '/saved', icon: Bookmark, description: 'Saved for later' },
    { name: 'Profile', href: `/profile/${user.username}`, icon: User, description: 'Your gallery' },
  ] : []

  const isActive = (href: string) => {
    if (href === '/') {
      return location.pathname === '/'
    }
    return location.pathname.startsWith(href)
  }

  return (
    <div className="sidebar">
      {/* Header */}
      <div className="flex items-center justify-between p-6 border-b border-border/50">
        <Link to="/" className="flex items-center space-x-3 group">
          <div className="relative">
            <div className="w-12 h-12 bg-gradient-primary rounded-3xl flex items-center justify-center shadow-modern-lg group-hover:shadow-modern-xl transition-all duration-300 group-hover:scale-110">
              <Palette className="h-6 w-6 text-white" />
            </div>
            <div className="absolute -top-1 -right-1 w-5 h-5 bg-gradient-to-br from-chart-1 to-chart-5 rounded-full flex items-center justify-center animate-pulse">
              <Sparkles className="h-2.5 w-2.5 text-white" />
            </div>
          </div>
          <div>
            <h1 className="text-xl font-bold gradient-text">ShittyDesigns</h1>
            <p className="text-xs text-muted-foreground">Embrace imperfect art</p>
          </div>
        </Link>
        
        {onClose && (
          <button
            onClick={onClose}
            className="lg:hidden p-2 hover:bg-accent rounded-2xl transition-all duration-300"
          >
            <X className="h-5 w-5" />
          </button>
        )}
      </div>

      {/* User Card */}
      {user && (
        <div className="p-6 border-b border-border/50">
          <div className="glass-card p-4">
            <div className="flex items-center space-x-3">
              {user.avatar_url ? (
                <img
                  src={user.avatar_url}
                  alt={user.username}
                  className="w-12 h-12 avatar"
                />
              ) : (
                <div className="w-12 h-12 bg-gradient-primary rounded-full flex items-center justify-center">
                  <User className="h-6 w-6 text-white" />
                </div>
              )}
              <div className="flex-1 min-w-0">
                <p className="font-medium text-foreground truncate">{user.username}</p>
                <p className="text-sm text-muted-foreground">{user.designs_count} designs</p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Navigation */}
      <nav className="flex-1 p-6 space-y-6">
        <div className="space-y-2">
          <h3 className="px-4 text-xs font-semibold text-muted-foreground uppercase tracking-wider">
            Discover
          </h3>
          {navigation.map((item) => (
            <Link
              key={item.name}
              to={item.href}
              onClick={onClose}
              className={`nav-item ${isActive(item.href) ? 'active' : ''}`}
            >
              <div className={`p-2 rounded-xl transition-all duration-300 ${
                isActive(item.href) 
                  ? 'bg-white/20' 
                  : 'bg-muted/50'
              }`}>
                <item.icon className="h-5 w-5" />
              </div>
              <div className="flex-1">
                <span className="font-medium text-sm">{item.name}</span>
                <p className="text-xs opacity-70">{item.description}</p>
              </div>
            </Link>
          ))}
        </div>

        {user && userNavigation.length > 0 && (
          <div className="space-y-2">
            <h3 className="px-4 text-xs font-semibold text-muted-foreground uppercase tracking-wider">
              Your Account
            </h3>
            {userNavigation.map((item) => (
              <Link
                key={item.name}
                to={item.href}
                onClick={onClose}
                className={`nav-item ${isActive(item.href) ? 'active' : ''}`}
              >
                <div className={`p-2 rounded-xl transition-all duration-300 ${
                  isActive(item.href) 
                    ? 'bg-white/20' 
                    : 'bg-muted/50'
                }`}>
                  <item.icon className="h-5 w-5" />
                </div>
                <div className="flex-1">
                  <span className="font-medium text-sm">{item.name}</span>
                  <p className="text-xs opacity-70">{item.description}</p>
                </div>
              </Link>
            ))}
          </div>
        )}
      </nav>

      {/* Stats Card */}
      <div className="p-6 border-t border-border/50">
        <div className="glass-card p-4">
          <h3 className="font-semibold text-sm mb-3 flex items-center space-x-2">
            <BarChart3 className="h-4 w-4" />
            <span>Community Stats</span>
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between text-xs">
              <span className="text-muted-foreground flex items-center space-x-1">
                <Palette className="h-3 w-3" />
                <span>Total Designs</span>
              </span>
              <span className="font-medium">12.4K</span>
            </div>
            <div className="flex justify-between text-xs">
              <span className="text-muted-foreground flex items-center space-x-1">
                <Users className="h-3 w-3" />
                <span>Active Artists</span>
              </span>
              <span className="font-medium">2.1K</span>
            </div>
            <div className="flex justify-between text-xs">
              <span className="text-muted-foreground flex items-center space-x-1">
                <Heart className="h-3 w-3" />
                <span>Likes Given</span>
              </span>
              <span className="font-medium">89.2K</span>
            </div>
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="p-6 border-t border-border/50">
        <div className="text-xs text-muted-foreground text-center space-y-1">
          <p>Made with ❤️ for imperfect artists</p>
          <p>© 2024 ShittyDesigns</p>
        </div>
      </div>
    </div>
  )
}

export default Sidebar