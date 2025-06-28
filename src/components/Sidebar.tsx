import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import { Home, Search, Upload, User, Palette, X, Sparkles, TrendingUp, Heart } from 'lucide-react'
import { useAuth } from '../contexts/AuthContext'

interface SidebarProps {
  onClose?: () => void
}

const Sidebar: React.FC<SidebarProps> = ({ onClose }) => {
  const location = useLocation()
  const { user } = useAuth()

  const navigation = [
    { name: 'Discover', href: '/', icon: Home, description: 'Latest designs' },
    { name: 'Trending', href: '/trending', icon: TrendingUp, description: 'Hot right now' },
    { name: 'Search', href: '/search', icon: Search, description: 'Find anything' },
    { name: 'Upload', href: '/upload', icon: Upload, description: 'Share your art', requireAuth: true },
    { name: 'Liked', href: '/liked', icon: Heart, description: 'Your favorites', requireAuth: true },
    { name: 'Profile', href: user ? `/profile/${user.username}` : '/auth', icon: User, description: 'Your gallery', requireAuth: true },
  ]

  const isActive = (href: string) => {
    if (href === '/') {
      return location.pathname === '/'
    }
    return location.pathname.startsWith(href)
  }

  return (
    <div className="sidebar-modern h-full flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <Link to="/" className="flex items-center space-x-3 group">
          <div className="relative">
            <div className="w-12 h-12 bg-gradient-to-br from-chart-1 via-chart-2 to-chart-3 rounded-2xl flex items-center justify-center shadow-lg group-hover:shadow-xl transition-all duration-300">
              <Palette className="h-6 w-6 text-white" />
            </div>
            <div className="absolute -top-1 -right-1 w-5 h-5 bg-gradient-to-br from-chart-4 to-chart-5 rounded-full flex items-center justify-center animate-pulse">
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
            className="lg:hidden btn-ghost p-2 rounded-xl"
          >
            <X className="h-5 w-5" />
          </button>
        )}
      </div>

      {/* User Card */}
      {user && (
        <div className="glass-card p-4 mb-6">
          <div className="flex items-center space-x-3">
            {user.avatar_url ? (
              <img
                src={user.avatar_url}
                alt={user.username}
                className="w-10 h-10 rounded-xl object-cover ring-2 ring-primary/20"
              />
            ) : (
              <div className="w-10 h-10 bg-gradient-to-br from-chart-1 to-chart-2 rounded-xl flex items-center justify-center">
                <User className="h-5 w-5 text-white" />
              </div>
            )}
            <div className="flex-1 min-w-0">
              <p className="font-medium text-sm truncate">{user.username}</p>
              <p className="text-xs text-muted-foreground">{user.designs_count} designs</p>
            </div>
          </div>
        </div>
      )}

      {/* Navigation */}
      <nav className="flex-1 space-y-2">
        {navigation.map((item) => {
          if (item.requireAuth && !user) return null
          
          return (
            <Link
              key={item.name}
              to={item.href}
              onClick={onClose}
              className={`group flex items-center space-x-4 px-4 py-3 rounded-2xl transition-all duration-200 ${
                isActive(item.href) 
                  ? 'bg-primary text-primary-foreground shadow-lg' 
                  : 'hover:bg-accent/50 text-foreground'
              }`}
            >
              <div className={`p-2 rounded-xl transition-colors ${
                isActive(item.href) 
                  ? 'bg-primary-foreground/20' 
                  : 'bg-muted group-hover:bg-primary/10'
              }`}>
                <item.icon className={`h-5 w-5 ${
                  isActive(item.href) ? 'text-primary-foreground' : 'text-muted-foreground group-hover:text-primary'
                }`} />
              </div>
              <div className="flex-1">
                <span className="font-medium text-sm">{item.name}</span>
                <p className={`text-xs ${
                  isActive(item.href) ? 'text-primary-foreground/70' : 'text-muted-foreground'
                }`}>
                  {item.description}
                </p>
              </div>
            </Link>
          )
        })}
      </nav>

      {/* Stats Card */}
      <div className="glass-card p-4 mt-6">
        <h3 className="font-semibold text-sm mb-3">Community Stats</h3>
        <div className="space-y-2">
          <div className="flex justify-between text-xs">
            <span className="text-muted-foreground">Total Designs</span>
            <span className="font-medium">12.4K</span>
          </div>
          <div className="flex justify-between text-xs">
            <span className="text-muted-foreground">Active Artists</span>
            <span className="font-medium">2.1K</span>
          </div>
          <div className="flex justify-between text-xs">
            <span className="text-muted-foreground">Likes Given</span>
            <span className="font-medium">89.2K</span>
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="pt-6 border-t border-border/50">
        <div className="text-xs text-muted-foreground text-center space-y-1">
          <p>Made with ❤️ for imperfect artists</p>
          <p>© 2024 ShittyDesigns</p>
        </div>
      </div>
    </div>
  )
}

export default Sidebar