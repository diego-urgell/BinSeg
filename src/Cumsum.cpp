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

public:

    Cumsum() = default;

    ~Cumsum() = default;

    /**
     * This init method computes the cumulative sum of the data array and stores it in a vector. It is virtual so that
     * it can be overridden in the CumsumSquared Class.
     * @param data The user input data
     * @param length The length of the data array
     */
    virtual void init(const double *data, const int length) {
        double currTotal = 0;
        this -> linearCumsum.resize(length);
        for(int i = 0; i < length; i++){
            currTotal += data[i];
            this -> linearCumsum[i] = currTotal;
        }
    }

    /**
     * This function allows to compute the cumulative sum from an start to end index in constant time, by
     * retrieving the values from the cumsum vector.
     * @param start inclusive
     * @param end inclusive
     * @return The Linear cumulative sum from start to end.
     */
    double getLinearSum(int start, int end) {
        if (start > end || start < 0) throw "Index Error";
        if (start == 0) return linearCumsum[end];
        return linearCumsum[end] - linearCumsum[start - 1];
    }

    /**
     * As this is Linear Cumsum, the method to get a quadratic cumsum should not be called, so it throws an exception.
     * However, it is virtual so it can be overridden in the CumusmSquared Class.
     * @param start inclusive
     * @param end inclusive
     * @return Runtime error if called.
     */
    virtual double getQuadraticSum(int start, int end){
        throw "No quadratic sum in LinearCumsum";
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
        if (start > end || start < 0) throw "Index Error";
        if (start == 0) return quadraticCumsum[end];
        return quadraticCumsum[end] - quadraticCumsum[start - 1];
    }
};
