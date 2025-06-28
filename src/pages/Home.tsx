import React, { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { useDesigns } from '../contexts/DesignsContext'
import { useAuth } from '../contexts/AuthContext'
import DesignCard from '../components/DesignCard'
import MasonryGrid from '../components/MasonryGrid'
import { Palette, Plus, TrendingUp, Users, Heart, Sparkles, ArrowRight, Zap } from 'lucide-react'
import { Link } from 'react-router-dom'

const Home: React.FC = () => {
  const { designs, loading, fetchDesigns } = useDesigns()
  const { user } = useAuth()
  const [userLikes, setUserLikes] = useState<string[]>([])

  useEffect(() => {
    fetchDesigns()
  }, [])

  useEffect(() => {
    if (user) {
      // Fetch user's likes
      // This would be implemented with a proper API call
    }
  }, [user])

  if (loading) {
    return (
      <div className="container-modern py-8">
        {/* Hero Section Skeleton */}
        <div className="text-center mb-16">
          <div className="h-16 skeleton w-96 mx-auto mb-6"></div>
          <div className="h-6 skeleton w-64 mx-auto mb-8"></div>
          <div className="flex justify-center space-x-4">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="h-12 w-32 skeleton"></div>
            ))}
          </div>
        </div>

        {/* Grid Skeleton */}
        <MasonryGrid>
          {Array.from({ length: 12 }).map((_, i) => (
            <div key={i} className="design-card">
              <div className="aspect-[3/4] skeleton mb-4"></div>
              <div className="p-5 space-y-3">
                <div className="h-5 skeleton"></div>
                <div className="h-4 skeleton w-3/4"></div>
                <div className="flex justify-between">
                  <div className="h-4 skeleton w-20"></div>
                  <div className="h-4 skeleton w-16"></div>
                </div>
              </div>
            </div>
          ))}
        </MasonryGrid>
      </div>
    )
  }

  return (
    <div className="container-modern py-8 space-modern">
      {/* Hero Section */}
      {!user && (
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="text-center mb-20"
        >
          <div className="flex justify-center mb-8">
            <div className="relative">
              <div className="w-24 h-24 bg-gradient-primary rounded-3xl flex items-center justify-center shadow-modern-2xl animate-float">
                <Palette className="h-12 w-12 text-white" />
              </div>
              <div className="absolute -top-2 -right-2 w-8 h-8 bg-gradient-to-br from-chart-1 to-chart-5 rounded-full flex items-center justify-center animate-pulse">
                <Sparkles className="h-4 w-4 text-white" />
              </div>
            </div>
          </div>
          
          <h1 className="text-responsive-xl font-black mb-6 text-balance">
            Welcome to{' '}
            <span className="gradient-text">ShittyDesigns</span>
          </h1>
          
          <p className="text-responsive-lg text-muted-foreground mb-12 max-w-3xl mx-auto text-balance">
            Where imperfect art finds its perfect home. Share your creativity without fear of judgment in our supportive community.
          </p>

          <div className="flex flex-wrap justify-center gap-6 mb-12">
            <div className="stats-card">
              <div className="w-12 h-12 bg-gradient-to-br from-chart-1 to-chart-2 rounded-2xl flex items-center justify-center mx-auto mb-3">
                <Heart className="h-6 w-6 text-white" />
              </div>
              <span className="font-medium">No judgment zone</span>
            </div>
            <div className="stats-card">
              <div className="w-12 h-12 bg-gradient-to-br from-chart-2 to-chart-3 rounded-2xl flex items-center justify-center mx-auto mb-3">
                <Users className="h-6 w-6 text-white" />
              </div>
              <span className="font-medium">Supportive community</span>
            </div>
            <div className="stats-card">
              <div className="w-12 h-12 bg-gradient-to-br from-chart-3 to-chart-4 rounded-2xl flex items-center justify-center mx-auto mb-3">
                <Sparkles className="h-6 w-6 text-white" />
              </div>
              <span className="font-medium">Celebrate creativity</span>
            </div>
          </div>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              to="/auth"
              className="btn btn-primary px-8 py-4 text-lg group"
            >
              Join the Community
              <ArrowRight className="ml-2 h-5 w-5 group-hover:translate-x-1 transition-transform" />
            </Link>
            <Link
              to="/search"
              className="btn btn-secondary px-8 py-4 text-lg"
            >
              Explore Designs
            </Link>
          </div>
        </motion.div>
      )}

      {/* Quick Actions for logged in users */}
      {user && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="mb-12"
        >
          <div className="glass-card p-8">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-2xl font-bold text-foreground mb-2">
                  Good to see you, {user.username}! ✨
                </h2>
                <p className="text-muted-foreground">Ready to share something amazing today?</p>
              </div>
              <Link
                to="/upload"
                className="btn btn-primary px-6 py-3 group"
              >
                <Plus className="h-5 w-5 mr-2 group-hover:rotate-90 transition-transform" />
                Create Pin
              </Link>
            </div>
          </div>
        </motion.div>
      )}

      {/* Stats Grid */}
      <motion.div 
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, delay: 0.2 }}
        className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16"
      >
        <div className="stats-card">
          <div className="flex items-center space-x-4 mb-4">
            <div className="p-3 bg-gradient-to-br from-chart-1 to-chart-2 rounded-2xl">
              <Palette className="h-6 w-6 text-white" />
            </div>
            <div>
              <div className="text-3xl font-bold">{designs.length}</div>
              <div className="text-muted-foreground text-sm">Amazing Designs</div>
            </div>
          </div>
        </div>
        
        <div className="stats-card">
          <div className="flex items-center space-x-4 mb-4">
            <div className="p-3 bg-gradient-to-br from-chart-2 to-chart-3 rounded-2xl">
              <Users className="h-6 w-6 text-white" />
            </div>
            <div>
              <div className="text-3xl font-bold">2.1K+</div>
              <div className="text-muted-foreground text-sm">Creative Artists</div>
            </div>
          </div>
        </div>
        
        <div className="stats-card">
          <div className="flex items-center space-x-4 mb-4">
            <div className="p-3 bg-gradient-to-br from-chart-3 to-chart-4 rounded-2xl">
              <Heart className="h-6 w-6 text-white" />
            </div>
            <div>
              <div className="text-3xl font-bold">89.2K+</div>
              <div className="text-muted-foreground text-sm">Likes Given</div>
            </div>
          </div>
        </div>
        
        <div className="stats-card">
          <div className="flex items-center space-x-4 mb-4">
            <div className="p-3 bg-gradient-to-br from-chart-4 to-chart-5 rounded-2xl">
              <TrendingUp className="h-6 w-6 text-white" />
            </div>
            <div>
              <div className="text-3xl font-bold">24/7</div>
              <div className="text-muted-foreground text-sm">Active Community</div>
            </div>
          </div>
        </div>
      </motion.div>

      {/* Designs Section */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.8, delay: 0.4 }}
      >
        <div className="flex justify-between items-center mb-8">
          <div>
            <h2 className="text-3xl font-bold mb-2">Latest Designs</h2>
            <p className="text-muted-foreground">Fresh creativity from our amazing community</p>
          </div>
          <div className="flex items-center space-x-2 text-sm text-muted-foreground glass-card px-4 py-2">
            <Zap className="h-4 w-4" />
            <span>{designs.length} designs shared</span>
          </div>
        </div>

        {designs.length === 0 ? (
          <div className="text-center py-24 glass-card">
            <Palette className="h-20 w-20 text-muted-foreground mx-auto mb-6" />
            <h3 className="text-2xl font-semibold mb-4">No designs yet</h3>
            <p className="text-muted-foreground mb-8">Be the first to share your amazing work!</p>
            {user && (
              <Link
                to="/upload"
                className="btn btn-primary px-6 py-3"
              >
                Upload Your First Design
              </Link>
            )}
          </div>
        ) : (
          <MasonryGrid>
            {designs.map((design, index) => (
              <motion.div
                key={design.id}
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.05 }}
              >
                <DesignCard design={design} userLikes={userLikes} />
              </motion.div>
            ))}
          </MasonryGrid>
        )}
      </motion.div>
    </div>
  )
}

export default Home