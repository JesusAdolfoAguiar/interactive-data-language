;+
;
;-
pro EEAjustImages
   
   ; Reference image
   baseName  = "C:\Users\User15\Documents\IDL\231-57-2015-RGB-1.tif"
   
   ; Image to be resized
   imageName = "C:\Users\User15\Documents\IDL\231-57-2015-RGB-1.tif"
   
   ; Out name.
   outName = "C:\Users\User15\Documents\IDL\231-57-2015-PRUEBA.tif AJ"
   
   ; Displacement between reference and displaced image
   xDesloc = 15.0
   yDesloc = -15.0
       
   envi_open_file, baseName, r_fid = bFid
   envi_open_data_file, imageName, r_fid = iFid, /tiff
   
   envi_file_query, bFid, dims = bDims
   envi_file_query, iFid, dims = iDims, nb = nb, bnames = bnames
   
   bMapInfo = envi_get_map_info(fid = bFid)
   iMapInfo = envi_get_map_info(fid = iFid)
   
   iMapInfo.MC[2] = iMapInfo.MC[2] + xDesloc
   iMapInfo.MC[3] = iMapInfo.MC[3] + yDesloc
   
   bULCornerX = bMapInfo.MC[2]
   bULCornerY = bMapInfo.MC[3]
   bDRCornerX = bMapInfo.MC[2] + ( 30. * ( bDims[2] + 1. ) ) 
   bDRCornerY = bMapInfo.MC[3] - ( 30. * ( bDims[4] + 1. ) )
   print, "Base:"
   print, bULCornerX, bULCornerY
   print, bDRCornerX, bDRCornerY  
   
   iULCornerX = iMapInfo.MC[2]
   iULCornerY = iMapInfo.MC[3]
   iDRCornerX = iMapInfo.MC[2] + ( 30. * ( iDims[2] + 1. ) )
   iDRCornerY = iMapInfo.MC[3] - ( 30. * ( iDims[4] + 1. ) )
   print, "Image:"
   print, iULCornerX, iULCornerY
   print, iDRCornerX, iDRCornerY
   
   print, "Delta"
   xULOffset = ceil((bULCornerX - iULCornerX)/30.)
   yULOffset = ceil((bULCornerY - iULCornerY)/30.)
   xDROffset = ceil((bDRCornerX - iDRCornerX)/30.)
   yDROffset = ceil((bDRCornerY - iDRCornerY)/30.)
   
   print, xULOffset
   print, yULOffset
   print, xDROffset
   print, yDROffset
   
   openW, lun, outName, /get_lun
   for i = 0, nb -1 do begin
      print, 'banda', i+1
      band = envi_get_data(fid = iFid, dims = iDims, pos = i)
      rBand = ResizeSameDims(temporary(band), $
                            iDims = iDims, $
                            bDims = bDims, $
                            xULOffset = xULOffset, $
                            xDROffset = xDROffset, $
                            yULOffset = yULOffset, $
                            yDROffset = yDROffset)
      writeU, lun, temporary(rBand)                                  
   endfor
   free_lun, lun
   
   envi_setup_head, fname = outName, $
                    bnames = bnames, $
                    file_type = 0, $
                    data_type = 1, $ ; 1 byte, 2 integer
                    ns = bDims[2] + 1, $
                    nl = bDims[4] + 1, $
                    nb = nb, $
                    pixel_size = [30., 30.], $
                    map_info = bMapInfo, $
                    interleave = 0, $
                    /write, $
                    /open
end
;+
;
;- 