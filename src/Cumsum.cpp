//
// Created by Diego Urgell on 10/06/21.
//

#include <vector>
#include <math.h>

/**
 * Compute a single time the linear cumulative sum of the data and store it. This will allow to obtain
 * the sum of the whole data or just a segment in linear time.
 */
class Cumsum {

protected:

    std::vector<double> linearCumsum;
    int length;

public:

    Cumsum() = default;

    virtual ~Cumsum() = default;

    /**
     * This init method computes the cumulative sum of the data array and stores it in a vector. It is virtual so that
     * it can be overridden in the CumsumSquared Class.
     * @param data The user input data
     * @param length The length of the data array.
     */
    virtual void init(const double *data, const int length) {
        this -> length = length;
        double currTotal = 0;
        this -> linearCumsum.resize(length);
        for(int i = 0; i < length; i++){
            currTotal += data[i];
            this -> linearCumsum[i] = currTotal;
        }
    }

    /**
     * This function allows to compute the cumulative sum from an start to end index in constant time, by
     * retrieving the values from the summaryStatistics vector.
     * @param start inclusive
     * @param end inclusive
     * @return The Linear cumulative sum from start to end.
     */
    double getLinearSum(int start, int end) {
        if (start < 0) throw "Index Error";
        if (start > end) return INFINITY;
        if (start == 0) return linearCumsum[end];
        return linearCumsum[end] - linearCumsum[start - 1];
    }

    /**
     * As this is Linear Cumsum, the method to get a quadratic summaryStatistics should not be called, so it throws an exception.
     * However, it is virtual so it can be overridden in the CumusmSquared Class.
     * @param start inclusive
     * @param end inclusive
     * @return Runtime error if called.
     */
    virtual double getQuadraticSum(int start, int end){
        throw "No quadratic sum in LinearCumsum";
    }

    double getTotalMean(){
        return this -> linearCumsum.back() / this -> length;
    }

    double getMean(int start, int end){
        return this -> getLinearSum(start, end) / (end - start + 1);
    }

    virtual double getVarianceN(int start, int end, bool fixedMean){
        throw "No variance with linear summaryStatistics";
    }
};


/**
 * Compute a single time the squared and linear cumulative sum of the data and store it, since it inherits from
 * Cumsum. This will allow to obtain the sum of the whole data or just a segment in linear time. In the algorithm
 * class, a CumsumLinear pointer will be stored so that polymorphism can be used to store CumsumSquared if necessary.
 */
class CumsumSquared: public Cumsum {

private:

    std::vector<double> quadraticCumsum;

public:

    CumsumSquared() = default;

    ~CumsumSquared() = default;

    /**
     * This method overrides the init method in the base Cumusm class. It initializes the quadraticSum vector along with
     * LinearSum in order to compute and store both vectors at the same time.
     * @param data The user's input data
     * @param length The length of the data vector.
     */
    void init(const double *data, const int length) {
        double currLinearTotal = 0;
        double currSquaredTotal = 0;
        this -> linearCumsum.resize(length);
        this -> quadraticCumsum.resize(length);
        this -> length = length;
        for(int i = 0; i < length; i++){
            currLinearTotal += data[i];
            currSquaredTotal += pow(data[i], 2);
            this -> linearCumsum[i] = currLinearTotal;
            this -> quadraticCumsum[i] = currSquaredTotal;
        }
    }

    /**
     * This method overrides the one from base Cumsum by providing the correct mechanism to compute a quadratic sum
     * in constant time.
     * @param start inclusive
     * @param end inclusive
     * @return The quadratic cumulative sum from start to end
     */
    double getQuadraticSum(int start, int end){
        if (start < 0) throw "Index Error";
        if (start > end) return INFINITY;
        if (start == 0) return quadraticCumsum[end];
        return quadraticCumsum[end] - quadraticCumsum[start - 1];
    }

    double getVarianceN(int start, int end, bool fixedMean){
        double lSum = this -> getLinearSum(start, end);
        double sSum =  this ->  getQuadraticSum(start, end);
        int N = end - start + 1;
        double mean = fixedMean ? this -> getTotalMean() : this -> getMean(start, end); // Fixed mean
        double varN = (sSum - 2 * mean * lSum + N * pow(mean, 2)); // Variance of segment.
        return varN;
    }
};
