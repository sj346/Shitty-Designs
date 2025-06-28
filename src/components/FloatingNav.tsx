import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import { Home, Search, Upload, User, Heart } from 'lucide-react'
import { useAuth } from '../contexts/AuthContext'

const FloatingNav: React.FC = () => {
  const location = useLocation()
  const { user } = useAuth()

  const navigation = [
    { name: 'Home', href: '/', icon: Home },
    { name: 'Search', href: '/search', icon: Search },
    { name: 'Upload', href: '/upload', icon: Upload },
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
    <nav className="lg:hidden floating-nav">
      <div className="flex items-center space-x-1">
        {navigation.map((item) => (
          <Link
            key={item.name}
            to={item.href}
            className={`flex flex-col items-center justify-center p-3 rounded-xl transition-all duration-200 ${
              isActive(item.href)
                ? 'bg-primary text-primary-foreground shadow-lg scale-110'
                : 'text-muted-foreground hover:text-foreground hover:bg-accent/50'
            }`}
          >
            <item.icon className="h-5 w-5 mb-1" />
            <span className="text-xs font-medium">{item.name}</span>
          </Link>
        ))}
      </div>
    </nav>
  )
}

export default FloatingNav