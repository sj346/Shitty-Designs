import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import { Home, Search, Upload, User, Heart, Plus } from 'lucide-react'
import { useAuth } from '../contexts/AuthContext'

const FloatingNav: React.FC = () => {
  const location = useLocation()
  const { user } = useAuth()

  const navigation = [
    { name: 'Home', href: '/', icon: Home },
    { name: 'Search', href: '/search', icon: Search },
    { name: 'Upload', href: '/upload', icon: Plus, special: true },
    { name: 'Liked', href: '/liked', icon: Heart },
    { name: 'Profile', href: user ? `/profile/${user.username}` : '/auth', icon: User },
  ]

  const isActive = (href: string) => {
    if (href === '/') {
      return location.pathname === '/'
    }
    return location.pathname.startsWith(href)
  }

  return (
    <nav className="lg:hidden fixed bottom-6 left-1/2 -translate-x-1/2 z-50">
      <div className="glass-card px-6 py-3">
        <div className="flex items-center space-x-2">
          {navigation.map((item) => (
            <Link
              key={item.name}
              to={item.href}
              className={`flex flex-col items-center justify-center p-3 rounded-2xl transition-all duration-300 ${
                item.special
                  ? 'bg-gradient-primary text-white shadow-modern-lg scale-110'
                  : isActive(item.href)
                  ? 'bg-primary/10 text-primary'
                  : 'text-muted-foreground hover:text-foreground hover:bg-accent/50'
              }`}
            >
              <item.icon className={`h-5 w-5 ${item.special ? 'mb-0' : 'mb-1'}`} />
              {!item.special && (
                <span className="text-xs font-medium">{item.name}</span>
              )}
            </Link>
          ))}
        </div>
      </div>
    </nav>
  )
}

export default FloatingNav