import React, { useState } from 'react'
import { Link } from 'react-router-dom'
import { Heart, MessageCircle, Share2, User, Eye, Download } from 'lucide-react'
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
  const [imageLoaded, setImageLoaded] = useState(false)
  const [showOverlay, setShowOverlay] = useState(false)

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
      try {
        await navigator.clipboard.writeText(`${window.location.origin}/design/${design.id}`)
      } catch (error) {
        console.error('Error copying to clipboard:', error)
      }
    }
  }

  return (
    <div className="pinterest-card group">
      <Link to={`/design/${design.id}`} className="block">
        {/* Image Container */}
        <div 
          className="relative overflow-hidden rounded-2xl bg-gray-100"
          onMouseEnter={() => setShowOverlay(true)}
          onMouseLeave={() => setShowOverlay(false)}
        >
          {!imageLoaded && (
            <div className="aspect-[3/4] bg-gray-200 animate-pulse flex items-center justify-center">
              <Eye className="h-8 w-8 text-gray-400" />
            </div>
          )}
          <img
            src={getOptimizedImageUrl(design.image_url, 400)}
            alt={design.title}
            className={`w-full h-auto object-cover transition-all duration-500 ${
              imageLoaded ? 'opacity-100' : 'opacity-0 absolute inset-0'
            } group-hover:scale-105`}
            loading="lazy"
            onLoad={() => setImageLoaded(true)}
          />
          
          {/* Hover Overlay */}
          <div className={`absolute inset-0 bg-black/40 transition-opacity duration-300 ${
            showOverlay ? 'opacity-100' : 'opacity-0'
          }`}>
            {/* Top Actions */}
            <div className="absolute top-4 right-4 flex space-x-2">
              <button
                onClick={handleLike}
                disabled={!user || isLoading}
                className={`p-2.5 rounded-full backdrop-blur-sm transition-all duration-200 ${
                  isLiked 
                    ? 'bg-red-500 text-white shadow-lg' 
                    : 'bg-white/90 text-gray-700 hover:bg-white'
                } ${!user ? 'opacity-50 cursor-not-allowed' : ''}`}
              >
                <Heart className={`h-4 w-4 ${isLiked ? 'fill-current' : ''}`} />
              </button>
              
              <button
                onClick={handleShare}
                className="p-2.5 rounded-full bg-white/90 text-gray-700 hover:bg-white backdrop-blur-sm transition-all duration-200"
              >
                <Share2 className="h-4 w-4" />
              </button>
            </div>

            {/* Bottom Info */}
            <div className="absolute bottom-4 left-4 right-4">
              <h3 className="font-semibold text-white text-lg mb-2 line-clamp-2">
                {design.title}
              </h3>
              
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  {design.user_avatar_url ? (
                    <img
                      src={design.user_avatar_url}
                      alt={design.user_name}
                      className="h-8 w-8 rounded-full object-cover ring-2 ring-white/50"
                    />
                  ) : (
                    <div className="h-8 w-8 bg-white/20 rounded-full flex items-center justify-center">
                      <User className="h-4 w-4 text-white" />
                    </div>
                  )}
                  <span className="text-white text-sm font-medium">{design.user_name}</span>
                </div>

                <div className="flex items-center space-x-3 text-white/80 text-sm">
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
            </div>
          </div>
        </div>

        {/* Card Footer - Always Visible */}
        <div className="p-4">
          <h3 className="font-semibold text-gray-900 mb-1 line-clamp-2">
            {design.title}
          </h3>
          
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
                  className="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-md"
                >
                  #{tag}
                </span>
              ))}
              {design.tags.length > 3 && (
                <span className="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-md">
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
                <div className="h-6 w-6 bg-gray-300 rounded-full flex items-center justify-center">
                  <User className="h-3 w-3 text-gray-600" />
                </div>
              )}
              <span className="text-sm text-gray-700">{design.user_name}</span>
            </div>

            <span className="text-xs text-gray-500">
              {formatDistanceToNow(new Date(design.created_at), { addSuffix: true })}
            </span>
          </div>
        </div>
      </Link>
    </div>
  )
}

export default DesignCard