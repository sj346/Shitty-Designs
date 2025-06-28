import React, { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { useDesigns } from '../contexts/DesignsContext'
import { useAuth } from '../contexts/AuthContext'
import DesignCard from '../components/DesignCard'
import MasonryGrid from '../components/MasonryGrid'
import { Palette, Plus, TrendingUp, Users, Heart } from 'lucide-react'
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
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Hero Section Skeleton */}
        <div className="text-center mb-12">
          <div className="h-12 bg-gray-200 rounded-lg w-96 mx-auto mb-4 animate-pulse"></div>
          <div className="h-6 bg-gray-200 rounded-lg w-64 mx-auto mb-8 animate-pulse"></div>
        </div>

        {/* Grid Skeleton */}
        <MasonryGrid>
          {Array.from({ length: 12 }).map((_, i) => (
            <div key={i} className="pinterest-card">
              <div className="aspect-[3/4] bg-gray-200 rounded-2xl animate-pulse mb-4"></div>
              <div className="p-4 space-y-3">
                <div className="h-5 bg-gray-200 rounded animate-pulse"></div>
                <div className="h-4 bg-gray-200 rounded w-3/4 animate-pulse"></div>
                <div className="flex justify-between">
                  <div className="h-4 bg-gray-200 rounded w-20 animate-pulse"></div>
                  <div className="h-4 bg-gray-200 rounded w-16 animate-pulse"></div>
                </div>
              </div>
            </div>
          ))}
        </MasonryGrid>
      </div>
    )
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Hero Section */}
      {!user && (
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="text-center mb-16"
        >
          <div className="flex justify-center mb-8">
            <div className="w-20 h-20 bg-gradient-to-br from-purple-500 to-pink-500 rounded-3xl flex items-center justify-center shadow-2xl">
              <Palette className="h-10 w-10 text-white" />
            </div>
          </div>
          
          <h1 className="text-5xl font-bold text-gray-900 mb-6">
            Welcome to <span className="text-purple-600">ShittyDesigns</span>
          </h1>
          
          <p className="text-xl text-gray-600 mb-12 max-w-2xl mx-auto">
            Where imperfect art finds its perfect home. Share your creativity without fear of judgment.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
            <Link
              to="/auth"
              className="px-8 py-4 bg-purple-500 text-white rounded-full hover:bg-purple-600 transition-colors font-medium text-lg"
            >
              Join the Community
            </Link>
            <Link
              to="/search"
              className="px-8 py-4 border border-gray-300 text-gray-700 rounded-full hover:bg-gray-50 transition-colors font-medium text-lg"
            >
              Explore Designs
            </Link>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-2xl mx-auto">
            <div className="text-center">
              <div className="w-12 h-12 bg-purple-100 rounded-2xl flex items-center justify-center mx-auto mb-3">
                <Palette className="h-6 w-6 text-purple-600" />
              </div>
              <div className="text-2xl font-bold text-gray-900">{designs.length}+</div>
              <div className="text-gray-600">Amazing Designs</div>
            </div>
            <div className="text-center">
              <div className="w-12 h-12 bg-blue-100 rounded-2xl flex items-center justify-center mx-auto mb-3">
                <Users className="h-6 w-6 text-blue-600" />
              </div>
              <div className="text-2xl font-bold text-gray-900">2.1K+</div>
              <div className="text-gray-600">Creative Artists</div>
            </div>
            <div className="text-center">
              <div className="w-12 h-12 bg-pink-100 rounded-2xl flex items-center justify-center mx-auto mb-3">
                <Heart className="h-6 w-6 text-pink-600" />
              </div>
              <div className="text-2xl font-bold text-gray-900">89.2K+</div>
              <div className="text-gray-600">Likes Given</div>
            </div>
          </div>
        </motion.div>
      )}

      {/* Quick Actions for logged in users */}
      {user && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="mb-8"
        >
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-2xl font-bold text-gray-900">Good to see you, {user.username}!</h2>
            <Link
              to="/upload"
              className="flex items-center space-x-2 px-6 py-3 bg-purple-500 text-white rounded-full hover:bg-purple-600 transition-colors"
            >
              <Plus className="h-5 w-5" />
              <span>Create Pin</span>
            </Link>
          </div>
        </motion.div>
      )}

      {/* Designs Grid */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.8, delay: 0.2 }}
      >
        {designs.length === 0 ? (
          <div className="text-center py-24">
            <Palette className="h-20 w-20 text-gray-300 mx-auto mb-6" />
            <h3 className="text-2xl font-semibold text-gray-600 mb-4">No designs yet</h3>
            <p className="text-gray-500 mb-8">Be the first to share your amazing work!</p>
            {user && (
              <Link
                to="/upload"
                className="inline-flex items-center space-x-2 px-6 py-3 bg-purple-500 text-white rounded-full hover:bg-purple-600 transition-colors"
              >
                <Plus className="h-5 w-5" />
                <span>Upload Your First Design</span>
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