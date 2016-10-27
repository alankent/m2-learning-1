FROM alankent/m2-luma
MAINTAINER Alan Kent <alan.james.kent@gmail.com>


########### Tutorial 1 Setup ########### 

# Add files for new module, but don't register them.
# Registering them is a part of the exercise.
ADD magento2 /magento2
RUN chown magento:magento app \
 && chown magento:magento app/code \
 && chown magento:magento -R app/code/Learning
