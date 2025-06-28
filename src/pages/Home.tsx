import React, { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { useDesigns } from '../contexts/DesignsContext'
import { useAuth } from '../contexts/AuthContext'
import DesignCard from '../components/DesignCard'
import MasonryGrid from '../components/MasonryGrid'
import { Palette, Sparkles, Heart, Users, TrendingUp, Zap, ArrowRight } from 'lucide-react'
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
      <div className="space-y-12">
        {/* Hero Section Skeleton */}
        <div className="glass-card p-12 text-center">
          <div className="h-16 bg-muted rounded-2xl w-96 mx-auto mb-6 loading-skeleton"></div>
          <div className="h-6 bg-muted rounded-xl w-64 mx-auto mb-8 loading-skeleton"></div>
          <div className="flex justify-center space-x-8">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="h-12 w-24 bg-muted rounded-xl loading-skeleton"></div>
            ))}
          </div>
        </div>

        {/* Grid Skeleton */}
        <div className="masonry-grid">
          {Array.from({ length: 12 }).map((_, i) => (
            <div key={i} className="masonry-item">
              <div className="card overflow-hidden">
                <div className="aspect-[4/5] bg-muted loading-skeleton"></div>
                <div className="p-5 space-y-3">
                  <div className="h-5 bg-muted rounded loading-skeleton"></div>
                  <div className="h-4 bg-muted rounded w-3/4 loading-skeleton"></div>
                  <div className="flex justify-between">
                    <div className="h-4 bg-muted rounded w-20 loading-skeleton"></div>
                    <div className="h-4 bg-muted rounded w-16 loading-skeleton"></div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-16">
      {/* Hero Section */}
      <motion.div 
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
        className="relative overflow-hidden glass-card p-12 text-center"
      >
        <div className="absolute inset-0 bg-gradient-to-br from-chart-1/10 via-chart-2/10 to-chart-3/10" />
        <div className="relative z-10">
          <div className="flex justify-center mb-8">
            <div className="relative">
              <div className="w-24 h-24 bg-gradient-to-br from-chart-1 via-chart-2 to-chart-3 rounded-3xl flex items-center justify-center shadow-2xl animate-float">
                <Palette className="h-12 w-12 text-white" />
              </div>
              <div className="absolute -top-2 -right-2 w-8 h-8 bg-gradient-to-br from-chart-4 to-chart-5 rounded-full flex items-center justify-center animate-pulse">
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

          <div className="flex flex-wrap justify-center gap-8 mb-12">
            <div className="flex items-center space-x-3 glass-card px-6 py-3">
              <Heart className="h-6 w-6 text-chart-1" />
              <span className="font-medium">No judgment zone</span>
            </div>
            <div className="flex items-center space-x-3 glass-card px-6 py-3">
              <Users className="h-6 w-6 text-chart-2" />
              <span className="font-medium">Supportive community</span>
            </div>
            <div className="flex items-center space-x-3 glass-card px-6 py-3">
              <Sparkles className="h-6 w-6 text-chart-3" />
              <span className="font-medium">Celebrate creativity</span>
            </div>
          </div>

          {!user && (
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                to="/auth"
                className="btn-primary px-8 py-4 text-lg btn-modern"
              >
                Join the Community
                <ArrowRight className="ml-2 h-5 w-5" />
              </Link>
              <Link
                to="/search"
                className="btn-secondary px-8 py-4 text-lg"
              >
                Explore Designs
              </Link>
            </div>
          )}
        </div>
      </motion.div>

      {/* Stats Grid */}
      <motion.div 
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, delay: 0.2 }}
        className="bento-grid"
      >
        <div className="bento-item col-span-1 sm:col-span-2 lg:col-span-1">
          <div className="flex items-center space-x-4 mb-4">
            <div className="p-3 bg-chart-1/20 rounded-2xl">
              <Palette className="h-6 w-6 text-chart-1" />
            </div>
            <div>
              <div className="text-3xl font-bold">{designs.length}</div>
              <div className="text-muted-foreground">Amazing Designs</div>
            </div>
          </div>
        </div>
        
        <div className="bento-item">
          <div className="flex items-center space-x-4 mb-4">
            <div className="p-3 bg-chart-2/20 rounded-2xl">
              <Users className="h-6 w-6 text-chart-2" />
            </div>
            <div>
              <div className="text-3xl font-bold">2.1K+</div>
              <div className="text-muted-foreground">Creative Artists</div>
            </div>
          </div>
        </div>
        
        <div className="bento-item">
          <div className="flex items-center space-x-4 mb-4">
            <div className="p-3 bg-chart-3/20 rounded-2xl">
              <Heart className="h-6 w-6 text-chart-3" />
            </div>
            <div>
              <div className="text-3xl font-bold">89.2K+</div>
              <div className="text-muted-foreground">Likes Given</div>
            </div>
          </div>
        </div>
        
        <div className="bento-item">
          <div className="flex items-center space-x-4 mb-4">
            <div className="p-3 bg-chart-4/20 rounded-2xl">
              <TrendingUp className="h-6 w-6 text-chart-4" />
            </div>
            <div>
              <div className="text-3xl font-bold">24/7</div>
              <div className="text-muted-foreground">Active Community</div>
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
                className="btn-primary px-6 py-3"
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
                transition={{ duration: 0.6, delay: index * 0.1 }}
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