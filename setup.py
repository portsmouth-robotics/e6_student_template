from setuptools import find_packages, setup

package_name = 'e6_student_template'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        (
            'share/ament_index/resource_index/packages',
            ['resource/' + package_name],
        ),
        (
            'share/' + package_name,
            ['package.xml'],
        ),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='University of Portsmouth Robotics Lab',
    maintainer_email='technologylabs@port.ac.uk',
    description='Student ROS 2 template package for the DOBOT Magician E6.',
    license='MIT',

    entry_points={
        'console_scripts': [
            'student_node = e6_student_template.student_node:main',
        ],
    },
)
