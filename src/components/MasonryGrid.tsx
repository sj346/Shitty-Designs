import React, { useEffect, useRef, useState } from 'react'

interface MasonryGridProps {
  children: React.ReactNode[]
  gap?: number
  minColumnWidth?: number
}

const MasonryGrid: React.FC<MasonryGridProps> = ({ 
  children, 
  gap = 20, 
  minColumnWidth = 280 
}) => {
  const containerRef = useRef<HTMLDivElement>(null)
  const [columns, setColumns] = useState(1)

  useEffect(() => {
    const updateColumns = () => {
      if (containerRef.current) {
        const containerWidth = containerRef.current.offsetWidth
        const newColumns = Math.max(1, Math.floor((containerWidth + gap) / (minColumnWidth + gap)))
        setColumns(newColumns)
      }
    }

    updateColumns()
    window.addEventListener('resize', updateColumns)
    return () => window.removeEventListener('resize', updateColumns)
  }, [minColumnWidth, gap])

  const columnArrays = Array.from({ length: columns }, () => [] as React.ReactNode[])
  
  children.forEach((child, index) => {
    const columnIndex = index % columns
    columnArrays[columnIndex].push(child)
  })

  return (
    <div ref={containerRef} className="w-full">
      <div 
        className="flex items-start"
        style={{ gap: `${gap}px` }}
      >
        {columnArrays.map((column, columnIndex) => (
          <div 
            key={columnIndex}
            className="flex-1 flex flex-col"
            style={{ gap: `${gap}px` }}
          >
            {column}
          </div>
        ))}
      </div>
    </div>
  )
}

export default MasonryGrid