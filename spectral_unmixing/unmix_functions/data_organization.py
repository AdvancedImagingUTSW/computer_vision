


# Create a Pandas DataFrame to store the results.
#movie_info = {'xCoord':[], 'yCoord':[], 'intensity':[],'eccentricity':[]}
#movie_info = pd.DataFrame(movie_info)
#final_properties = regionprops(final_labels, image_data)

#label_counter = 0
#for label in range(int(np.max(final_labels))):
#    if final_properties[label_counter]['area'] > minimum_eb3_area:
#        centroid = final_properties[label_counter]['centroid']
#        xidx = centroid[0]
#        yidx = centroid[1]
#        temp = pd.DataFrame({'xCoord':[xidx],
#                                'yCoord':[yidx],
#                                'intensity':[final_properties[label_counter]['max_intensity']],
#                                'eccentricity':[final_properties[label_counter]['eccentricity']]})
#        movie_info = pd.concat([movie_info, temp], ignore_index=True)
#    label_counter += 1
#movie_info.head()
