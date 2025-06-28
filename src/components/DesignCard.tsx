import React, { useState } from 'react'
import { Link } from 'react-router-dom'
import { Heart, MessageCircle, Share2, MoreHorizontal, User, Eye } from 'lucide-react'
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
    <div className="masonry-item">
      <Link to={`/design/${design.id}`} className="design-card block">
        {/* Image Container */}
        <div className="relative overflow-hidden">
          {!imageLoaded && (
            <div className="aspect-[4/5] bg-muted animate-pulse flex items-center justify-center">
              <Eye className="h-8 w-8 text-muted-foreground" />
            </div>
          )}
          <img
            src={getOptimizedImageUrl(design.image_url, 400)}
            alt={design.title}
            className={`w-full h-auto object-cover transition-all duration-500 ${
              imageLoaded ? 'opacity-100' : 'opacity-0 absolute inset-0'
            }`}
            loading="lazy"
            onLoad={() => setImageLoaded(true)}
          />
          
          {/* Overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-all duration-300">
            <div className="absolute bottom-4 left-4 right-4 flex items-center justify-between">
              <div className="flex space-x-2">
                <button
                  onClick={handleLike}
                  disabled={!user || isLoading}
                  className={`p-2.5 rounded-xl backdrop-blur-sm transition-all duration-200 ${
                    isLiked 
                      ? 'bg-red-500 text-white shadow-lg' 
                      : 'bg-white/20 text-white hover:bg-red-500/20'
                  } ${!user ? 'opacity-50 cursor-not-allowed' : ''}`}
                >
                  <Heart className={`h-4 w-4 ${isLiked ? 'fill-current' : ''}`} />
                </button>
                
                <button
                  onClick={handleShare}
                  className="p-2.5 rounded-xl bg-white/20 text-white hover:bg-blue-500/20 backdrop-blur-sm transition-all duration-200"
                >
                  <Share2 className="h-4 w-4" />
                </button>
              </div>
              
              <button className="p-2.5 rounded-xl bg-white/20 text-white hover:bg-gray-500/20 backdrop-blur-sm transition-all duration-200">
                <MoreHorizontal className="h-4 w-4" />
              </button>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="p-5">
          {/* Title */}
          <h3 className="font-semibold text-foreground mb-2 line-clamp-2 text-lg">
            {design.title}
          </h3>

          {/* Description */}
          {design.description && (
            <p className="text-sm text-muted-foreground mb-4 line-clamp-2">
              {design.description}
            </p>
          )}

          {/* Tags */}
          {design.tags && design.tags.length > 0 && (
            <div className="flex flex-wrap gap-1.5 mb-4">
              {design.tags.slice(0, 3).map((tag, index) => (
                <span
                  key={index}
                  className="inline-block px-2.5 py-1 text-xs bg-muted text-muted-foreground rounded-lg font-medium"
                >
                  #{tag}
                </span>
              ))}
              {design.tags.length > 3 && (
                <span className="inline-block px-2.5 py-1 text-xs bg-muted text-muted-foreground rounded-lg font-medium">
                  +{design.tags.length - 3}
                </span>
              )}
            </div>
          )}

          {/* User info and stats */}
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              {design.user_avatar_url ? (
                <img
                  src={design.user_avatar_url}
                  alt={design.user_name}
                  className="h-8 w-8 rounded-xl object-cover ring-2 ring-border"
                />
              ) : (
                <div className="h-8 w-8 bg-gradient-to-br from-chart-1 to-chart-2 rounded-xl flex items-center justify-center">
                  <User className="h-4 w-4 text-white" />
                </div>
              )}
              <div>
                <span className="text-sm font-medium text-foreground">{design.user_name}</span>
                <p className="text-xs text-muted-foreground">
                  {formatDistanceToNow(new Date(design.created_at), { addSuffix: true })}
                </p>
              </div>
            </div>

            <div className="flex items-center space-x-4 text-sm text-muted-foreground">
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
      </Link>
    </div>
  )
}

export default DesignCard