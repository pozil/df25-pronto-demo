import { LightningElement, api } from "lwc";

export default class ReviewStars extends LightningElement {
  @api reviewScore;
  @api numberOfReviews;
  @api showScore;

  get stars() {
    const stars = [];
    const reviewScore =
      this.reviewScore === undefined ? 0 : Math.round(this.reviewScore);
    for (let i = 0; i < 5; i++) {
      stars.push({
        index: i,
        iconName: i < reviewScore ? "utility:favorite" : "utility:favorite_alt"
      });
    }
    return stars;
  }

  get label() {
    if (this.showScore)
      return `Score of ${this.reviewScore} based on ${this.numberOfReviews} reviews`;
    return `(${this.numberOfReviews})`;
  }
}
