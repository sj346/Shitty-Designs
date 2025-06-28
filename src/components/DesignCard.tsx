import React, { useState } from 'react'
import { Link } from 'react-router-dom'
import { Heart, MessageCircle, Share2, MoreHorizontal, User } from 'lucide-react'
import { Design } from '../types'
import { useAuth } from '../contexts/AuthContext'
import { useDesigns } from '../contexts/DesignsContext'
import { formatDistanceToNow } from 'date-fns'
import { getOptimizedImageUrl } from '../lib/supabase'

interface DesignCardProps {
  design: Design
  userLikes?: string[]
}

const DesignCard: React.FC<DesignCardProps> = ({ design, userLikes = [] }) => {
  const { user } = useAuth()
  const { likeDesign, unlikeDesign } = useDesigns()
  const [isLiked, setIsLiked] = useState(userLikes.includes(design.id))
  const [likesCount, setLikesCount] = useState(design.likes_count)
  const [isLoading, setIsLoading] = useState(false)

  const handleLike = async (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    
    if (!user) return
    
    setIsLoading(true)
    try {
      if (isLiked) {
        await unlikeDesign(design.id)
        setIsLiked(false)
        setLikesCount(prev => Math.max(0, prev - 1))
      } else {
        await likeDesign(design.id)
        setIsLiked(true)
        setLikesCount(prev => prev + 1)
      }
    } catch (error) {
      console.error('Error toggling like:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const handleShare = async (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    
    if (navigator.share) {
      try {
        await navigator.share({
          title: design.title,
          text: design.description || 'Check out this design on ShittyDesigns!',
          url: `${window.location.origin}/design/${design.id}`
        })
      } catch (error) {
        console.error('Error sharing:', error)
      }
    } else {
      // Fallback to clipboard
      try {
        await navigator.clipboard.writeText(`${window.location.origin}/design/${design.id}`)
        // You could show a toast here
      } catch (error) {
        console.error('Error copying to clipboard:', error)
      }
    }
  }

  return (
    <div className="masonry-item">
      <Link to={`/design/${design.id}`} className="design-card group block">
        {/* Image */}
        <div className="relative overflow-hidden">
          <img
            src={getOptimizedImageUrl(design.image_url, 400)}
            alt={design.title}
            className="w-full h-auto object-cover transition-transform duration-300 group-hover:scale-105"
            loading="lazy"
          />
          
          {/* Overlay on hover */}
          <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-20 transition-all duration-300 flex items-center justify-center opacity-0 group-hover:opacity-100">
            <div className="flex space-x-2">
              <button
                onClick={handleLike}
                disabled={!user || isLoading}
                className={`p-2 rounded-full transition-all duration-200 ${
                  isLiked 
                    ? 'bg-red-500 text-white' 
                    : 'bg-white text-gray-700 hover:bg-red-50 hover:text-red-500'
                } ${!user ? 'opacity-50 cursor-not-allowed' : ''}`}
              >
                <Heart className={`h-4 w-4 ${isLiked ? 'fill-current' : ''}`} />
              </button>
              
              <button
                onClick={handleShare}
                className="p-2 rounded-full bg-white text-gray-700 hover:bg-blue-50 hover:text-blue-500 transition-all duration-200"
              >
                <Share2 className="h-4 w-4" />
              </button>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="p-4">
          {/* Title */}
          <h3 className="font-semibold text-gray-900 mb-2 line-clamp-2">
            {design.title}
          </h3>

          {/* Description */}
          {design.description && (
            <p className="text-sm text-gray-600 mb-3 line-clamp-2">
              {design.description}
            </p>
          )}

          {/* Tags */}
          {design.tags && design.tags.length > 0 && (
            <div className="flex flex-wrap gap-1 mb-3">
              {design.tags.slice(0, 3).map((tag, index) => (
                <span
                  key={index}
                  className="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-full"
                >
                  #{tag}
                </span>
              ))}
              {design.tags.length > 3 && (
                <span className="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-full">
                  +{design.tags.length - 3}
                </span>
              )}
            </div>
          )}

          {/* User info and stats */}
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              {design.user_avatar_url ? (
                <img
                  src={design.user_avatar_url}
                  alt={design.user_name}
                  className="h-6 w-6 rounded-full object-cover"
                />
              ) : (
                <div className="h-6 w-6 bg-primary-500 rounded-full flex items-center justify-center">
                  <User className="h-3 w-3 text-white" />
                </div>
              )}
              <span className="text-sm text-gray-600">{design.user_name}</span>
            </div>

            <div className="flex items-center space-x-3 text-sm text-gray-500">
              <div className="flex items-center space-x-1">
                <Heart className="h-4 w-4" />
                <span>{likesCount}</span>
              </div>
              <div className="flex items-center space-x-1">
                <MessageCircle className="h-4 w-4" />
                <span>{design.comments_count}</span>
              </div>
            </div>
          </div>

          {/* Time */}
          <div className="mt-2 text-xs text-gray-400">
            {formatDistanceToNow(new Date(design.created_at), { addSuffix: true })}
          </div>
        </div>
      </Link>
    </div>
  )
}

export default DesignCard