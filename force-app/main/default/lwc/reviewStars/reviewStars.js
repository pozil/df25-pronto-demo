import { LightningElement, api } from "lwc";

export default class ReviewStars extends LightningElement {
  _reviewScore = 0;
  stars = [];

  @api
  set reviewScore(value) {
    this._reviewScore = value;
    const stars = [];
    for (let i = 0; i < 5; i++) {
      stars.push({
        index: i,
        iconName: i <= value ? "utility:favorite" : "utility:favorite_alt"
      });
    }
    this.stars = stars;
  }
  get reviewScore() {
    return this._reviewScore;
  }

  @api numberOfReviews;
}
