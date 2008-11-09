#include<stdio.h>

double finddet(double a1,double a2, double a3,double b1, double b2,double b3, double c1, double c2, double c3); 

void main()
{
     double a1, a2, a3, b1, b2, b3, c1, c2, c3, d1, d2, d3,det, detx, dety, detz;
     
     printf("\n a1?"); /*Input Coefficients*/
     scanf("%lf",&a1);
     printf("\n b1?");
     scanf("%lf",&b1);
     printf("\n c1?");
     scanf("%lf",&c1);
     printf("\n d1?");
     scanf("%lf",&d1);
     printf("\n a2?");
     scanf("%lf",&a2);
     printf("\n b2?");
     scanf("%lf",&b2);
     printf("\n c2?");
     scanf("%lf",&c2);
     printf("\n d2?");
     scanf("%lf",&d2);
     printf("\n a3?");
     scanf("%lf",&a3);
     printf("\n b3?");
     scanf("%lf",&b3);
     printf("\n c3?");
     scanf("%lf",&c3);
     printf("\n d3?");
     scanf("%lf",&d3);

     det=finddet(a1,a2,a3,b1,b2,b3,c1,c2,c3);   /*Find determinants*/
     detx=finddet(d1,d2,d3,b1,b2,b3,c1,c2,c3);
     dety=finddet(a1,a2,a3,d1,d2,d3,c1,c2,c3);
     detz=finddet(a1,a2,a3,b1,b2,b3,d1,d2,d3);
     
     if(d1==0 && d2==0 && d3==0 && det==0)
          printf("\n Infinite Solutions\n ");
     else if(d1==0 && d2==0 && d3==0 && det!=0)   /*Print Answers depending on various conditions*/
          printf("\n x=0\n y=0, \n z=0\n ");
     else if(det!=0)
          printf("\n x=%lf\n y=%lf\n z=%lf\n", (detx/det), (dety/det), (detz/det));
     else if(det==0 && detx==0 && dety==0 && detz==0)
          printf("\n Infinite Solutions\n ");
     else
          printf("No Solution\n ");

}

double finddet(double a1,double a2, double a3,double b1, double b2,double b3, double c1, double c2, double c3)
{
     return ((a1*b2*c3)-(a1*b3*c2)-(a2*b1*c3)+(a3*b1*c2)+(a2*b3*c1)-(a3*b2*c1)); /*expansion of a 3x3 determinant*/
}



