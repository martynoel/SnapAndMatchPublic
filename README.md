# Snap & Match
*A color-savvy, UO-loving personal stylist for your phone.*

![pic](http://asianbarbie.com/wp-content/uploads/2017/08/matchingComplimentary.gif)

- [Blog writeup](http://asianbarbie.com/snap-and-match/)

### Note: This repo is meant to be viewed only and cannot run on a device because the backend code is not included due to propreitary restrictions. 

## Team
- **Mimi Chenyao** | Tech Lead, iOS developer 
- **Billy Groble** | Backend developer
- **Natalie Orcutt** | UX/UI designer

## Screenshots
![Choose Category screen](http://asianbarbie.com/wp-content/uploads/2017/08/snm_screen_1_s.jpg)
![Choose Photo screen](http://asianbarbie.com/wp-content/uploads/2017/08/snm_screen_2_s.jpg)
![Take Photo screen](http://asianbarbie.com/wp-content/uploads/2017/08/snm_screen_3_s.jpg)
![Get Results screen](http://asianbarbie.com/wp-content/uploads/2017/08/snm_screen_4_s.jpg)
![Product View screen](http://asianbarbie.com/wp-content/uploads/2017/08/snm_screen_5_s.jpg)  

## Inspiration
Color-wise, people tend to stick to their comfort zones when shopping for new clothes. They want to experiment with different colors, but aren’t sure where to begin. Snap & Match makes this process easy by taking into account the colors you already own, and suggesting clothes that could compliment items in your existing wardrobe. The app uses color theory to make its matches. 

Currently, Snap & Match will give you Urban Outfitters clothing suggestions, and matches complementary colors. For example, if you’re looking for new shoes and snap a picture of your purple dress, the app will give you suggestions for yellow shoes from UO. 

## How it Works
![](http://asianbarbie.com/wp-content/uploads/2017/08/Screen-Shot-2017-08-06-at-8.49.03-PM.png) 
-
We utilized the Google Cloud Vision and Urban Outfitters Catalog APIs in Snap & Match’s backend. When users click “Use Photo”, the Google Vision API detects the dominant color of that image. That color’s complementary color is determined and passed, along with the user’s selected clothing category, to the Urban Outfitters Catalog API, which gives back clothing suggestions. 

## Future Improvements
In the future, Snap & Match will have more match options based on other color theories, such as analogous, monochrome, triad, or split-complementary. It will also suggest clothing items from other brands. 

## Contact 
If you liked this project, check out [my personal blog](http://asianbarbie.com/). You can reach out to me through [Twitter](https://twitter.com/mimichenyao) or [LinkedIn](https://www.linkedin.com/in/mimichenyao).
