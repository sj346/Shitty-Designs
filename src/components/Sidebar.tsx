import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import { Home, Search, Upload, User, Palette, X, TrendingUp, Heart, Bookmark } from 'lucide-react'
import { useAuth } from '../contexts/AuthContext'

interface SidebarProps {
  onClose?: () => void
}

const Sidebar: React.FC<SidebarProps> = ({ onClose }) => {
  const location = useLocation()
  const { user } = useAuth()

  const navigation = [
    { name: 'Home', href: '/', icon: Home },
    { name: 'Trending', href: '/trending', icon: TrendingUp },
    { name: 'Search', href: '/search', icon: Search },
  ]

  const userNavigation = user ? [
    { name: 'Create', href: '/upload', icon: Upload },
    { name: 'Liked', href: '/liked', icon: Heart },
    { name: 'Saved', href: '/saved', icon: Bookmark },
    { name: 'Profile', href: `/profile/${user.username}`, icon: User },
  ] : []

  const isActive = (href: string) => {
    if (href === '/') {
      return location.pathname === '/'
    }
    return location.pathname.startsWith(href)
  }

  return (
    <div className="h-full bg-white border-r border-gray-200 flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between p-6 border-b border-gray-100">
        <Link to="/" className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl flex items-center justify-center shadow-lg">
            <Palette className="h-5 w-5 text-white" />
          </div>
          <div>
            <h1 className="text-xl font-bold text-gray-900">ShittyDesigns</h1>
            <p className="text-xs text-gray-500">Embrace imperfect art</p>
          </div>
        </Link>
        
        {onClose && (
          <button
            onClick={onClose}
            className="lg:hidden p-2 hover:bg-gray-100 rounded-xl transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        )}
      </div>

      {/* User Card */}
      {user && (
        <div className="p-6 border-b border-gray-100">
          <div className="flex items-center space-x-3">
            {user.avatar_url ? (
              <img
                src={user.avatar_url}
                alt={user.username}
                className="w-12 h-12 rounded-full object-cover"
              />
            ) : (
              <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center">
                <User className="h-6 w-6 text-white" />
              </div>
            )}
            <div className="flex-1 min-w-0">
              <p className="font-medium text-gray-900 truncate">{user.username}</p>
              <p className="text-sm text-gray-500">{user.designs_count} designs</p>
            </div>
          </div>
        </div>
      )}

      {/* Navigation */}
      <nav className="flex-1 p-6 space-y-2">
        <div className="space-y-1">
          {navigation.map((item) => (
            <Link
              key={item.name}
              to={item.href}
              onClick={onClose}
              className={`group flex items-center space-x-3 px-4 py-3 rounded-xl transition-all ${
                isActive(item.href) 
                  ? 'bg-purple-50 text-purple-600' 
                  : 'hover:bg-gray-50 text-gray-700'
              }`}
            >
              <item.icon className={`h-5 w-5 ${
                isActive(item.href) ? 'text-purple-600' : 'text-gray-500'
              }`} />
              <span className="font-medium">{item.name}</span>
            </Link>
          ))}
        </div>

        {user && userNavigation.length > 0 && (
          <>
            <div className="pt-6 pb-2">
              <h3 className="px-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                Your Account
              </h3>
            </div>
            <div className="space-y-1">
              {userNavigation.map((item) => (
                <Link
                  key={item.name}
                  to={item.href}
                  onClick={onClose}
                  className={`group flex items-center space-x-3 px-4 py-3 rounded-xl transition-all ${
                    isActive(item.href) 
                      ? 'bg-purple-50 text-purple-600' 
                      : 'hover:bg-gray-50 text-gray-700'
                  }`}
                >
                  <item.icon className={`h-5 w-5 ${
                    isActive(item.href) ? 'text-purple-600' : 'text-gray-500'
                  }`} />
                  <span className="font-medium">{item.name}</span>
                </Link>
              ))}
            </div>
          </>
        )}
      </nav>

      {/* Footer */}
      <div className="p-6 border-t border-gray-100">
        <div className="text-xs text-gray-500 space-y-1">
          <p>© 2024 ShittyDesigns</p>
          <p>Made with ❤️ for artists</p>
        </div>
      </div>
    </div>
  )
}

export default Sidebar